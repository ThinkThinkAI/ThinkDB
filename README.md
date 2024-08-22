# ThinkDB

ThinkDB empowers you to effortlessly navigate and manage your databases, eliminating the need for deep SQL expertise. 🧙‍♂️✨ Leveraging advanced AI capabilities, ThinkDB intuitively understands your objectives and translates them into precise SQL queries. Whether you are a seasoned database professional or a newcomer to the world of data management, ThinkDB provides an intuitive and natural interface to help you explore, query, and manage your data with unparalleled ease.

**In essence, ThinkDB is a sophisticated web-based database client designed for both simplicity and power.**

---
## ⚠️ Alpha Software Warning ⚠️

**Important Notice:** ThinkDB is currently in the alpha stage of development. This means that the software is still undergoing changes and may contain bugs or incomplete features. We recommend using ThinkDB in a test environment and not in a production setting until a stable release is available. Your feedback is valuable to us and can help shape the final product.
---


## Current Features

- **Multi-Database Support:** Seamlessly interact with SQLite, MySQL, and PostgreSQL databases, all from a single unified interface.
- **Intelligent SQL Autocompletion:** Experience faster query writing with smart autocompletion in the SQL editor, reducing errors and improving efficiency.
- **AI-Driven SQL Generation:** Generate complex SQL queries from simple natural language inputs, allowing you to articulate your needs without getting bogged down in syntax.
- **Query Management:** Save and organize your frequently used queries, enabling quick access and reuse for future sessions.
- **Table Browser:** Explore your database structures with a robust table browser that offers insights into table schemas and relationships.

## Upcoming Features

- **Expanded Database Support:** We are actively working to broaden the range of supported databases, ensuring compatibility with more systems.
- **AI-Powered Database Optimization:** Soon, you will be able to consult our AI for guidance on optimizing your database schema and structure, making your database more efficient and scalable.
- **User Administration:** Enhanced user management capabilities will be introduced, allowing for more granular control over access and permissions.

## Security Considerations

- **Privacy by Design:** Only database schemas are sent to the AI for processing—no actual table data is transmitted, ensuring the confidentiality of your information.
- **Principled Approach:** We believe that offering database clients as a service poses significant security risks; therefore, ThinkDB is designed to operate securely on your own infrastructure.
- **Encrypted Communication:** All connection information is securely encrypted, safeguarding your credentials and ensuring that your data remains protected at all times.
- **Database Security:** We believe database security should be managed on the database itself, reinforcing access controls and preventing unauthorized access.


## Getting Started

### Using Docker (The Simplest Method)

To get ThinkDB up and running quickly, you can utilize Docker:

```bash
git clone git@github.com:ThinkThinkAI/ThinkDB.git
cd ThinkDB
docker-compose up --build
```

### Running on Ruby on Rails

If you prefer to run ThinkDB locally within the Ruby on Rails environment.

```bash
git clone git@github.com:ThinkThinkAI/ThinkDB.git
cd ThinkDB
bundle install
rails db:migrate
rails s
```