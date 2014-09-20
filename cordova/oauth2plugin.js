(function() {
    "use strict";
    var OAuth2Plugin = function() {
        var that = this;

        var argscheck = require('cordova/argscheck'),
            utils = require('cordova/utils'),
            exec = require('cordova/exec');


        // status will be:
        // unlinked
        // firstSync
        // syncing
        // synced

        this.getStatusFull = function(callback) {
            exec(callback, null, "OAuth2Plugin", "getStatusFull", []);
        };


        this.signIn = function() {
            exec(null, null, "OAuth2Plugin", "signInToCustomService", []);
        };

        this.signOut = function() {
            exec(null, null, "OAuth2Plugin", "signOut", []);
        };



    };

    module.exports = window.OAuth2Plugin = new OAuth2Plugin();
})();