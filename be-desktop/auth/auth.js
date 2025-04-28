const jwt = require('jsonwebtoken');
const response = require('../response');

const authenticateJWT = (req, res, next) => {
    const authHeader = req.header('Authorization');

    if (!authHeader) {
        return response(401, null, "Akses ditolak, silahkan login terlebih dahulu", res);
    }

    const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : authHeader;

    try {
        const verified = jwt.verify(token, process.env.JWT_SECRET);
        req.user = verified;
        next();
    } catch (err) {
        response(400, null, "Token tidak valid", res)
    }
};

const authorizeRoles = (...allowedRoles) => {
    return (req, res, next) => {
        if (!allowedRoles.includes(req.user.role)) {
            return response(403, null, "Forbidden: Anda tidak memiliki izin", res);
        }
        next();
    };
};

module.exports = { authenticateJWT, authorizeRoles };
