exports.handler = async (event, context) => {
  // Simply echo the data back to the caller
  const body = JSON.parse(event.body || '{}');
  const data = body.data;
  console.log(data);
  
  return {
    statusCode: 200,
    body: JSON.stringify({
      data: data
    })
  };
};