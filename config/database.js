module.exports = ({ env }) => ({
  connection: {
    client: 'postgres',
    connection: {
      host: 'localhost',
      port: 5432,
      database: 'strapidb',
      user: 'postgres',
      password: 'admin123',
      ssl: false,
    },
  },
});
