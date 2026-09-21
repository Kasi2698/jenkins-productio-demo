const express = require('express');

const app = express();
app.disable('x-powered-by');

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'OK' });
});

/* istanbul ignore next */
if (require.main === module) {
  app.listen(3000, () => {
    console.log('Server running on port 3000');
  });
}

module.exports = app;
