mutable struct GenericCamera <: CameraBase
    mPosition::vec3
    mRotationMatrix::mat3
    mLookAtDistance::Float32
    mAspectRatio::Float32

    function GenericCamera()
        this = new()
        this.mLookAtDistance = 500.0
        this.mAspectRatio = 4.0 / 3.0
        setRotationMatrix(this, mat3(1I))
        return this
    end
end

function setRotationMatrix(this::GenericCamera, _matrix::mat3)
    this.mRotationMatrix = _matrix;
    @assert isOrthonormalMatrix(this.mRotationMatrix) "Rotation matrix must be orthonormal!"
end

function getRotationMatrix4(this::GenericCamera)::mat4
    return mat4(this.mRotationMatrix)
end

function getTranslationMatrix4(this::GenericCamera)::mat4
    trans = mat4(1I)
    trans[4, 1] = -mPosition.x;
    trans[4, 2] = -mPosition.y;
    trans[4, 3] = -mPosition.z;
    return trans
end

function setTarget(this::GenericCamera, _target::vec3)
    setTarget(this, _target, getUpDirection(this))
end

function getUpDirection(this::GenericCamera)::vec3
    up = vec3(this.mRotationMatrix[1, 2], this.mRotationMatrix[2, 2], this.mRotationMatrix[3, 2])
    @assert (distance(getInverseRotationMatrix3(this) * vec3(0.0, 1.0, 0.0), up) < .01)
    return up
end

function getInverseRotationMatrix3(this::GenericCamera)::mat3
    return transpose(this.mRotationMatrix)
end

function setTarget(this::GenericCamera, _target::vec3, _up::vec3)
    forwardVector::vec3 = _target - this.mPosition
    this.mLookAtDistance = norm(forwardVector)
    if (this.mLookAtDistance < .0001) # in case target == mPosition
        this.mLookAtDistance = .0001
        forwardVector = vec3(this.mLookAtDistance, 0, 0)
    end

    forwardVector = forwardVector / this.mLookAtDistance; # normalize
    rightVector::vec3 = normalize(cross(forwardVector, _up))
    upVector::vec3 = cross(rightVector, forwardVector)

    rotMatrix = mat3(rightVector[1], upVector[1], -forwardVector[1],
                     rightVector[2], upVector[2], -forwardVector[2],
                     rightVector[3], upVector[3], -forwardVector[3])

    setRotationMatrix(this, rotMatrix)
end

function getTarget(this::GenericCamera)::vec3
    return this.mPosition + getForwardDirection(this) * getLookAtDistance(this)
end

function getForwardDirection(this::GenericCamera)::vec3
    forward = vec3(-this.mRotationMatrix[1, 3], -this.mRotationMatrix[2, 3], -this.mRotationMatrix[3, 3])
    @assert (distance(getInverseRotationMatrix3() * vec3(0.0f, 0.0f, -1.0f), forward) < .01)
    return forward
end

function getLookAtDistance(this::GenericCamera)::Float32
    return this.mLookAtDistance
end

function setAspectRatio(this::GenericCamera, _aspectRatio::Float32)
    this.mAspectRatio = _aspectRatio
end

function setPosition(this::GenericCamera, _position::vec3)
    this.mPosition = _position
end

function getPosition(this::GenericCamera)::vec3
    return this.mPosition
end

function rotateAroundTarget_GlobalAxes(this::GenericCamera, _x::Float32, _y::Float32, _z::Float32)
    # move camera so, that the target is the center, then rotate around the
    # global coordinate system
    rotateAroundTaget_helper(_x, _y, _z, mat3(1I))
end

function rotateAroundTaget_helper(this::GenericCamera, _x::Float32, _y::Float32, _z::Float32, _rotationAxes::mat3)
    T = vec4(getTarget(this), 1.0f)
    P = vec4(getPosition(this), 1.0f)

    tempPos = P - T;
    newRotation = rotate(mat4(1I), _x, _rotationAxes[1]);
    newRotation = rotate(newRotation, _y, _rotationAxes[2]);
    newRotation = rotate(newRotation, _z, _rotationAxes[3]);

    tempPos = newRotation * tempPos

    P = tempPos + T; # new position
    N = vec4(getUpDirection(), 1.0f);
    N = newRotation * N;

    setLookAtMatrix(this, vec3(P), vec3(T), vec3(N))
end

function setLookAtMatrix(this::GenericCamera, _position::vec3, _target::vec3, _up::vec3)
    setPosition(this, _position)
    setTarget(this, _target, _up)
end

function GenericCamera::getViewMatrix(this::GenericCamera)::mat4
    if (this.mStereoMode == Mono)
        return getMonoViewMatrix(this)
    else
        # all kinds of stereo
        eyeIsLeftEye = (getEye() == EyeLeft)
        return getStereoViewMatrix(this, eyeIsLeftEye, this.mStereoMode)
    end
end

function GenericCamera::getMonoViewMatrix(this::GenericCamera)::mat4
    m = mat4(mRotationMatrix)
    m[3][0] = -(m[0][0] * mPosition.x + m[1][0] * mPosition.y +
                m[2][0] * mPosition.z);
    m[3][1] = -(m[0][1] * mPosition.x + m[1][1] * mPosition.y +
                m[2][1] * mPosition.z);
    m[3][2] = -(m[0][2] * mPosition.x + m[1][2] * mPosition.y +
                m[2][2] * mPosition.z);
    @assert (isApproxEqual(getRotationMatrix4() * getTranslationMatrix4(), m));
    return m
end

function GenericCamera::getStereoViewMatrix(bool _leftEye, StereoMode _stereoMode)::mat4
    # The view matrix is independent of the projection mode (isometric or
    # perspective)
    # so only the stereo mode has to be checked.
    @assert (_stereoMode != Mono && "mono is not a stereo mode!");

    float cameraPositionShiftValue =
        (mInterpupillaryDistance * 0.5f); # shift to the right
    if (_leftEye)
        cameraPositionShiftValue *= -1.0f; # if left eye shift to the left
    end

    if ((_stereoMode == ParallelShift) || (_stereoMode == OffAxis)) {
        #
        # parallel shift and off-axis have the same view matrices:
        # just shift the camera position to the left/right by half the
        # eye-distance
        #

        # ACGL::Utils::debug() << "WARNING: getStereoViewMatrix() is not tested
        # yet" << std::endl; // remove after
        # testing

        glm::mat3 inverseRotation = getInverseRotationMatrix3();
        glm::vec3 eyePosition =
            mPosition +
            (inverseRotation * glm::vec3(cameraPositionShiftValue, 0.0f, 0.0f));

        glm::mat4 m(mRotationMatrix);
        m[3][0] = -(m[0][0] * eyePosition.x + m[1][0] * eyePosition.y +
                    m[2][0] * eyePosition.z);
        m[3][1] = -(m[0][1] * eyePosition.x + m[1][1] * eyePosition.y +
                    m[2][1] * eyePosition.z);
        m[3][2] = -(m[0][2] * eyePosition.x + m[1][2] * eyePosition.y +
                    m[2][2] * eyePosition.z);
        return m;
    end

    # else it has to be toe-in:
    assert(_stereoMode == ToeIn && "unsupported stereo mode!");
    #
    # Toe-in: shift the camera position to the left/right by half the
    # eye-distance and
    #         rotate a bit inwards so that the two cameras focus the same point
    #         at the look-at distance (focal point)

    assert(0 && "getStereoViewMatrix() for TOE_IN is not implemented yet!");
    return glm::mat4(1.0f);
end

glm::mat4 GenericCamera::getProjectionMatrix() const {
    if (mStereoMode == Mono) {
        return getMonoProjectionMatrix();
    } else {
        # all kinds of stereo
        bool eyeIsLeftEye = (getEye() == EyeLeft);
        return getStereoProjectionMatrix(eyeIsLeftEye, mStereoMode);
    }
}

function getMonoProjectionMatrix(this::GenericCamera)::mat4
    glm::mat4 projectionMatrix{}; # identity matrix

    if (getProjectionMode() == IsometricProjection) {
        # we don't set the left/right/top/bottom values explicitly, so we want
        # that
        # all object at our focal distance appear the same in perspective and
        # isometric view
        float right = tan(glm::radians(getHorizontalFieldOfView() * 0.5f)) *
                      mLookAtDistance;
        float left = -right;
        float top = tan(glm::radians(getVerticalFieldOfView() * 0.5f)) *
                    mLookAtDistance;
        float bottom = -top;

        # we do the same here as a glOrtho call would do, but with flipped y
        projectionMatrix[0][0] = 2.0f / (right - left);
        projectionMatrix[1][1] = -2.0f / (top - bottom);
        projectionMatrix[2][2] =
            -2.0f / (mFarClippingPlane - mNearClippingPlane);
        projectionMatrix[0][3] = -(right + left) / (right - left);
        projectionMatrix[1][3] = -(top + bottom) / (top - bottom);
        projectionMatrix[2][3] = -(mFarClippingPlane + mNearClippingPlane) /
                                 (mFarClippingPlane - mNearClippingPlane);
        projectionMatrix[3][3] = 1.0;
    elseif (mProjectionMode == PerspectiveProjectionOpenGL)
        if (std::isinf(mFarClippingPlane))
            float e = 1.0f / tan(glm::radians(getVerticalFieldOfView() * 0.5f));
            const float a = getAspectRatio();

            # infinite Perspective matrix reversed mapping to 1..-1
            projectionMatrix = {e / a, 0.0f, 0.0f,                      0.0f,
                                0.0f,  -e,    0.0f,                     0.0f,
                                0.0f,  0.0f, -1.0f,                     -1.0f,
                                0.0f,  0.0f, -2.0 * mNearClippingPlane, 0.0f};
        else
            projectionMatrix = glm::perspective(
                glm::radians((float)getHorizontalFieldOfView()),
                (float)getAspectRatio(), (float)mNearClippingPlane,
                (float)mFarClippingPlane);
            projectionMatrix[0][1] *= -1.f;
            projectionMatrix[1][1] *= -1.f;
            projectionMatrix[2][1] *= -1.f;
            projectionMatrix[3][1] *= -1.f;
        end
    elseif (mProjectionMode == PerspectiveProjectionDXReverse)
        if (std::isinf(mFarClippingPlane))
            float e = 1.0f / tan(glm::radians(getVerticalFieldOfView() * 0.5f));
            const float a = getAspectRatio();

            # infinite Perspective matrix reversed mapping to 1..0, but flip y
            projectionMatrix = {e / a, 0.0f, 0.0f,               0.0f,  #
                                0.0f,  -e,    0.0f,               0.0f,  #
                                0.0f,  0.0f, 0.0f,               -1.0f, #
                                0.0f,  0.0f, mNearClippingPlane, 0.0f};
        else
            assert(0 && "unsupported projection mode")
        end
    else
        assert(0 && "unsupported projection mode")
    end

    return projectionMatrix
end

function getStereoProjectionMatrix(this::GenericCamera, _leftEye::Bool, StereoMode _stereoMode)::mat4
    assert(_stereoMode != Mono && "mono is not a stereo mode!");

    if (getProjectionMode() == IsometricProjection)
        # very unusual, prepare for headaches!
        return getMonoProjectionMatrix();
    end

    if ((_stereoMode == ParallelShift) || (_stereoMode == ToeIn))
        # the view matrix changes but the projection matrix stays the same
        return getMonoProjectionMatrix();
    end

    # so off-axis it is!
    assert(_stereoMode == OffAxis && "unknown projection mode!");
    #
    # In this mode the camera positions (view matrix) is shifted to the
    # left/right still looking
    # straight ahead. The projection is also looking ahead but the projection
    # center is
    # off (hence off-axis).
    # There is one plane in front of the cameras where the view-frusta match.
    # This should be the distance to the physical screen from the users
    # position.

    assert(0 && "getStereoViewMatrix() is not implemented for OFF_AXIS yet!");
    return mat4(1I)
end