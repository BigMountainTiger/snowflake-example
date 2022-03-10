require('dotenv').config({ path: '/opt/nodejs/common/.env' });
const slack = require('/opt/nodejs/common/slack');

exports.handler = async (event, context) => {

  // https://aws.amazon.com/sns/faqs/
  // All notification messages will contain a single published message
  const record = event.Records[0];
  console.log(record);

  const sns = record.Sns;
  const data = {
    subject: sns.Subject,
    message: sns.Message
  };

  console.log(data);

  const CHANNELS = 'U0101CPEW5U';
  const channels = CHANNELS.split('|');
  const msg = (() => {
    let msg = `${data.subject || ''} \`\`\`${data.message}\`\`\``
    msg = `Snowflake error notificaton\n${msg}`;

    return msg;
  })();

  for (const channel of channels) {
    console.log(`Sending slack message to ${channel}`);
    try { await slack.send({ channel: channel, text: msg }); } catch (e) { console.error(e); }
  }
  
  return {
    statusCode: 200,
    body: 'OK'
  };
};