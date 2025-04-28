const response = (statusCode, data, message, res) => {
    res.json([
        {
            statusCode,
            payload: data,
            message,
            metadata: {
                prev : "",
                next : "",
                max : "",
                current : ""
            },
        },
    ])
}

module.exports = response;
