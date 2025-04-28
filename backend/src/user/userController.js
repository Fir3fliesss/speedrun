const db = require('../../db');

    exports.createUser = async (req, res) => {
        const { username, email, password, full_name, role } = req.body;

        try {
            const [result] = await db.execute(
                `INSERT INTO users (username, email, full_name, password, role) VALUES (?, ?, ?, ?, ?)`,
                [ username, email, full_name, 'passwordhash', user ]
            );
            res.status(201).json({ mesage: "User created!", id: result.insertId })
        } catch (error) {
            res.status(500).json({ erro: error.message });
        }
    };

    exports.getUsers = async (req, res) => {
        try {
        const [users] = await db.execute('SELECT id, username, email, full_name FROM users');
        res.json(users);
        } catch (err) {
        res.status(500).json({ error: err.message });
        }
    };
    
    exports.updateUser = async (req, res) => {
        const { id } = req.params;
        const { full_name } = req.body;
        try {
        await db.execute('UPDATE users SET full_name = ? WHERE id = ?', [full_name, id]);
        res.json({ message: 'User updated' });
        } catch (err) {
        res.status(500).json({ error: err.message });
        }
    };
  
  exports.deleteUser = async (req, res) => {
    const { id } = req.params;
    try {
      await db.execute('DELETE FROM users WHERE id = ?', [id]);
      res.json({ message: 'User deleted' });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };