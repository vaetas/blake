const address = 'ws://localhost:4041';

function connect() {
  try {
    const socket = new WebSocket(address);
    socket.onmessage = function() {
      location.reload();
    };
    socket.onclose = function() {
      console.log('Connection closed.')
      connect();
    }
  } catch (error) {
    console.log(`Error ${error}`);
    setInterval(() => {
      connect();
    }, 1000);
  }
}

connect();
