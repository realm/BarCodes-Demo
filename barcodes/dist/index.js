"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const realm_object_server_1 = require("realm-object-server");
const path = require("path");
const server = new realm_object_server_1.BasicServer();
server.start({
    dataPath: path.join(__dirname, '../data'),
    authProviders: [new realm_object_server_1.auth.NicknameAuthProvider()]
})
    .then(() => {
    console.log(`Realm Object Server was started on ${server.address}`);
})
    .catch(err => {
    console.error(`Error starting Realm Object Server: ${err.message}`);
});
//# sourceMappingURL=index.js.map