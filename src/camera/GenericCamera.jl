# use the DX reverse mode with:
# * an infinite far plane
# * a float z-buffer
# * glClearDepth(0.0)
# * glDepthFunc(GL_GREATER)
# * either:
#     * glClipControl(GL_LOWER_LEFT, GL_ZERO_TO_ONE) (DX style mapping of the Z values)
#   or:
#     * glDepthRangedNV(-1.0, 1.0)
#
# this way near will get mapped to 1.0 and infinite to 0.0
@enum ProjectionMode begin
    IsometricProjection = 0
    PerspectiveProjectionOpenGL    # maps to -1..1
    PerspectiveProjectionDXReverse # maps to  1..0, ideal for Vulkan too
end

@enum StereoMode begin
    Mono = 0
    ParallelShift
    OffAxis
    ToeIn
end

mutable struct GenericCamera <: CameraBase
    mPosition::Vec3f0
    mRotationMatrix::Mat3f0
    mLookAtDistance::Float32
    mAspectRatio::Float32
    mStereoMode::StereoMode
    mNearClippingPlane::Float32
    mFarClippingPlane::Float32
    mProjectionMode::ProjectionMode
    mHorizontalFieldOfView::Float32

    function GenericCamera()
        this = new(zero(Vec3f0), Mat3f0(1I), 500.0, 4.0 / 3.0, Mono, 0.1, Inf, PerspectiveProjectionDXReverse, 75.0)
        setRotationMatrix(this, Mat3f0(1I))
        return this
    end
end

@class GenericCamera

function setRotationMatrix(this::GenericCamera, _matrix::Mat3f0)
    this.mRotationMatrix = _matrix
    @assert isOrthonormalMatrix(this.mRotationMatrix) "Rotation matrix must be orthonormal!"
end

function getRotationMatrix4(this::GenericCamera)::Mat4f0
    return make_mat4(this.mRotationMatrix)
end

function getTranslationMatrix4(this::GenericCamera)::Mat4f0
    trans = make_mat4(Mat3f0(1I), -this.mPosition.x, -this.mPosition.y, -this.mPosition.z, 1f0)
    return trans
end

function setTarget(this::GenericCamera, _target::Vec3f0)
    setTarget(this, _target, getUpDirection(this))
end

function getUpDirection(this::GenericCamera)::Vec3f0
    up = Vec3f0(this.mRotationMatrix[1, 2], this.mRotationMatrix[2, 2], this.mRotationMatrix[3, 2])
    @assert (distance(col_multiple(getInverseRotationMatrix3(this), Vec3f0(0.0, 1.0, 0.0)), up) < .01)
    return up
end

function getInverseRotationMatrix3(this::GenericCamera)::Mat3f0
    return transpose(this.mRotationMatrix)
end

function setTarget(this::GenericCamera, _target::Vec3f0, _up::Vec3f0)
    forwardVector::Vec3f0 = _target - this.mPosition
    this.mLookAtDistance = norm(forwardVector)
    if (this.mLookAtDistance < .0001) # in case target == mPosition
        this.mLookAtDistance = .0001
        forwardVector = Vec3f0(this.mLookAtDistance, 0, 0)
    end

    forwardVector = forwardVector / this.mLookAtDistance # normalize
    rightVector::Vec3f0 = normalize(cross(forwardVector, _up))
    upVector::Vec3f0 = cross(rightVector, forwardVector)

    rotMatrix = Mat3f0([rightVector[1] upVector[1] -forwardVector[1];
                    rightVector[2] upVector[2] -forwardVector[2];
                    rightVector[3] upVector[3] -forwardVector[3]])

    setRotationMatrix(this, rotMatrix)
end

function getTarget(this::GenericCamera)::Vec3f0
    return this.mPosition + getForwardDirection(this) * getLookAtDistance(this)
end

function getForwardDirection(this::GenericCamera)::Vec3f0
    forward = Vec3f0(-this.mRotationMatrix[1, 3], -this.mRotationMatrix[2, 3], -this.mRotationMatrix[3, 3])
    inv = getInverseRotationMatrix3(this)
    @assert (distance(col_multiple(inv, Vec3f0(0, 0, -1)), forward) < .01)
    return forward
end

function getLookAtDistance(this::GenericCamera)::Float32
    return this.mLookAtDistance
end

function setAspectRatio(this::GenericCamera, _aspectRatio::Float32)
    this.mAspectRatio = _aspectRatio
end

function setPosition(this::GenericCamera, _position::Vec3f0)
    this.mPosition = _position
end

function getPosition(this::GenericCamera)::Vec3f0
    return this.mPosition
end

function rotateAroundTarget_GlobalAxes(this::GenericCamera, _x::Float32, _y::Float32, _z::Float32)
    # move camera so, that the target is the center, then rotate around the
    # global coordinate system
    rotateAroundTaget_helper(this, _x, _y, _z, Mat3f0(1I))
end

function rotateAroundTaget_helper(this::GenericCamera, _x::Float32, _y::Float32, _z::Float32, _rotationAxes::Mat3f0)
    T = make_vec4(getTarget(this), 1.0)
    P = make_vec4(getPosition(this), 1.0)

    tempPos = P - T
    newRotation = rotate(RotMatrix(Mat3f0(1I)), _x, getRow(_rotationAxes, 1))
    newRotation = rotate(newRotation, _y, getRow(_rotationAxes, 2))
    newRotation = rotate(newRotation, _z, getRow(_rotationAxes, 3))
    newRotation = make_mat4(Mat3f0(newRotation))
    tempPos = col_multiple(newRotation, tempPos)

    P = tempPos + T # new position
    N = make_vec4(getUpDirection(this), 1.0)
    N = col_multiple(newRotation, N)

    setLookAtMatrix(this, make_vec3(P), make_vec3(T), make_vec3(N))
end

function setLookAtMatrix(this::GenericCamera, _position::Vec3f0, _target::Vec3f0, _up::Vec3f0)
    setPosition(this, _position)
    setTarget(this, _target, _up)
end

function getViewMatrix(this::GenericCamera)::Mat4f0
    if (this.mStereoMode == Mono)
        return getMonoViewMatrix(this)
    else
        # all kinds of stereo
        eyeIsLeftEye = (getEye(this) == EyeLeft)
        return getStereoViewMatrix(this, eyeIsLeftEye, this.mStereoMode)
    end
end

function getMonoViewMatrix(this::GenericCamera)::Mat4f0
    m = this.mRotationMatrix
    m41 = -(m[1, 1] * this.mPosition.x + m[2, 1] * this.mPosition.y +
                m[3, 1] * this.mPosition.z)
    m42 = -(m[1, 2] * this.mPosition.x + m[2, 2] * this.mPosition.y +
                m[3, 2] * this.mPosition.z)
    m43 = -(m[1, 3] * this.mPosition.x + m[2, 3] * this.mPosition.y +
                m[3, 3] * this.mPosition.z)
    m = make_mat4(m, m41, m42, m43, 1f0)
    @assert (isApproxEqual(col_multiple(getRotationMatrix4(this), getTranslationMatrix4(this)), m))
    return m
end

function getStereoViewMatrix(this::GenericCamera, _leftEye::Bool, _stereoMode::StereoMode)::Mat4f0
    # The view matrix is independent of the projection mode (isometric or
    # perspective)
    # so only the stereo mode has to be checked.
    @assert _stereoMode != Mono "mono is not a stereo mode!"

    cameraPositionShiftValue::Float32 = this.mInterpupillaryDistance * 0.5 # shift to the right
    if (_leftEye)
        cameraPositionShiftValue *= -1.0 # if left eye shift to the left
    end

    if ((_stereoMode == ParallelShift) || (_stereoMode == OffAxis))
        #
        # parallel shift and off-axis have the same view matrices:
        # just shift the camera position to the left/right by half the
        # eye-distance
        #

        # ACGL::Utils::debug(this) << "WARNING: getStereoViewMatrix(this) is not tested
        # yet" << std::endl // remove after
        # testing

        inverseRotation = getInverseRotationMatrix3(this)
        eyePosition::Vec3f0 = this.mPosition + col_multiple(inverseRotation, Vec3f0(cameraPositionShiftValue, 0.0, 0.0))

        m = make_mat4(this.mRotationMatrix)
        m[4, 1] = -(m[1, 1] * eyePosition.x + m[2, 1] * eyePosition.y +
                    m[3, 1] * eyePosition.z)
        m[4, 2] = -(m[1, 2] * eyePosition.x + m[2, 2] * eyePosition.y +
                    m[3, 2] * eyePosition.z)
        m[4, 3] = -(m[1, 3] * eyePosition.x + m[2, 3] * eyePosition.y +
                    m[3, 3] * eyePosition.z)
        return m
    end

    # else it has to be toe-in:
    @assert (_stereoMode == ToeIn) "unsupported stereo mode!"
    #
    # Toe-in: shift the camera position to the left/right by half the
    # eye-distance and
    #         rotate a bit inwards so that the two cameras focus the same point
    #         at the look-at distance (focal point)

    @assert false "getStereoViewMatrix(this) for TOE_IN is not implemented yet!"
    return Mat4f0(1I)
end

function getProjectionMatrix(this::GenericCamera)::Mat4f0
    if (this.mStereoMode == Mono)
        return getMonoProjectionMatrix(this)
    else
        # all kinds of stereo
        eyeIsLeftEye = getEye(this) == EyeLeft
        return getStereoProjectionMatrix(this, eyeIsLeftEye, this.mStereoMode)
    end
end

function getProjectionMode(this::GenericCamera)::ProjectionMode
    return this.mProjectionMode
end

function getVerticalFieldOfView(this::GenericCamera)::Float32
    rad2deg(atan(tan(deg2rad(0.5 * this.mHorizontalFieldOfView)) / this.mAspectRatio) * 2.0)
end

function getAspectRatio(this::GenericCamera)::Float32
    return this.mAspectRatio
end

function getMonoProjectionMatrix(this::GenericCamera)::Mat4f0
    projectionMatrix = Mat4f0(1I) # identity matrix

    if (getProjectionMode(this) == IsometricProjection)
        # we don't set the left/right/top/bottom values explicitly, so we want
        # that
        # all object at our focal distance appear the same in perspective and
        # isometric view
        right::Float32 = tan(deg2rad(getHorizontalFieldOfView(this) * 0.5)) * this.mLookAtDistance
        left::Float32 = -right
        top::Float32 = tan(deg2rad(getVerticalFieldOfView(this) * 0.5f)) * this.mLookAtDistance
        bottom::Float32 = -top

        # we do the same here as a glOrtho call would do, but with flipped y
        projectionMatrix[1, 1] = 2.0 / (right - left)
        projectionMatrix[2, 2] = -2.0 / (top - bottom)
        projectionMatrix[3, 3] = -2.0 / (this.mFarClippingPlane - mNearClippingPlane)
        projectionMatrix[1, 4] = -(right + left) / (right - left)
        projectionMatrix[2, 4] = -(top + bottom) / (top - bottom)
        projectionMatrix[3, 4] = -(this.mFarClippingPlane + mNearClippingPlane) /
                                  (this.mFarClippingPlane - mNearClippingPlane)
        projectionMatrix[4, 4] = 1.0
    elseif (this.mProjectionMode == PerspectiveProjectionOpenGL)
        if (std::isinf(this.mFarClippingPlane))
            e = 1.01 / tan(deg2rad(getVerticalFieldOfView(this) * 0.5))
            a = getAspectRatio(this)

            # infinite Perspective matrix reversed mapping to 1..-1
            projectionMatrix = Mat4f0([e / a 0.0 0.0  0.0;
                                     0.0   -e  0.0  0.0;
                                     0.0   0.0 -1.0 -1.0;
                                     0.0   0.0 -2.0 * this.mNearClippingPlane 0.0])
        else
            projectionMatrix = glm::perspective(
                deg2rad(getHorizontalFieldOfView(this)),
                getAspectRatio(this), this.mNearClippingPlane,
                this.mFarClippingPlane)
            projectionMatrix[1, 2] *= -1.0
            projectionMatrix[2, 2] *= -1.0
            projectionMatrix[3, 2] *= -1.0
            projectionMatrix[4, 2] *= -1.0
        end
    elseif (this.mProjectionMode == PerspectiveProjectionDXReverse)
        if (isinf(this.mFarClippingPlane))
            e = 1.0 / tan(deg2rad(getVerticalFieldOfView(this) * 0.5))
            a = getAspectRatio(this)

            # infinite Perspective matrix reversed mapping to 1..0, but flip y
            projectionMatrix = Mat4f0([e / a 0.0 0.0  0.0;  #
                                     0.0   -e  0.0  0.0;  #
                                     0.0   0.0 0.0 -1.0; #
                                     0.0   0.0 this.mNearClippingPlane 0.0])
        else
            @assert false "unsupported projection mode"
        end
    else
        @assert false "unsupported projection mode"
    end

    return projectionMatrix
end

function getStereoProjectionMatrix(this::GenericCamera, _leftEye::Bool, _stereoMode::StereoMode)::Mat4f0
    @assert (_stereoMode != Mono) "mono is not a stereo mode!"

    if (getProjectionMode(this) == IsometricProjection)
        # very unusual, prepare for headaches!
        return getMonoProjectionMatrix(this)
    end

    if ((_stereoMode == ParallelShift) || (_stereoMode == ToeIn))
        # the view matrix changes but the projection matrix stays the same
        return getMonoProjectionMatrix(this)
    end

    # so off-axis it is!
    @assert (_stereoMode == OffAxis) "unknown projection mode!"
    #
    # In this mode the camera positions (view matrix) is shifted to the
    # left/right still looking
    # straight ahead. The projection is also looking ahead but the projection
    # center is
    # off (hence off-axis).
    # There is one plane in front of the cameras where the view-frusta match.
    # This should be the distance to the physical screen from the users
    # position.

    @assert false "getStereoViewMatrix(this) is not implemented for OFF_AXIS yet!"
    return Mat4f0(1I)
end
