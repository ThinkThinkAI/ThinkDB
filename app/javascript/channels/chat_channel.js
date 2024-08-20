import consumer from "channels/consumer";

document.addEventListener("turbo:load", () => {
  const currentUserId = document.getElementById("current-user-id").value;

  if (currentUserId) {
    const chatChannel = consumer.subscriptions.create(
      { channel: "ChatChannel", user_id: currentUserId },
      {
        connected() {},
        disconnected() {},
        received(data) {
          if (data.ai_response) {
            const messagesDiv = document.getElementById("messages");
            const scrollboxDiv = document.getElementById("messages-scrollbox");
            const loadingMessagesDiv =
              document.getElementById("loading-message");

            const existingMessageDiv = document.getElementById(
              `message-${data.message_id}`
            );
            if (existingMessageDiv) {
              return; 
            }

            if (loadingMessagesDiv) {
              loadingMessagesDiv.remove();
            }

            if (messagesDiv) {
              const newMessageDiv = document.createElement("div");
              newMessageDiv.id = `message-${data.message_id}`;
              newMessageDiv.innerHTML = data.ai_response;
              messagesDiv.appendChild(newMessageDiv);

              initializeGrid(
                data.message_id,
                data.message_sql.replace(/;/g, "")
              );

              scrollboxDiv.scrollTop = messagesDiv.scrollHeight;
            } else {
              console.error(
                'Element with ID "messages" not found on the page.'
              );
            }
          } else {
            console.error("No ai_response key in the received data:", data);
          }
        },
        rejected() {
          console.error("Subscription to ChatChannel was rejected");
        },
      }
    );
  } else {
    console.error("current-user-id not found on the page");
  }
});
