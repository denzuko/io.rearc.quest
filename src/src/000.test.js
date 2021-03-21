const express    = require('express'),
      request    = require('supertest'),
      bodyParser = require("body-parser"),
      app        = express();
      routes     = require('000');

app.use(bodyParser.json());
app.use('/', routes);

describe("Should respond to http requests", () => {

    it("GET / - success", async () => {
        await request(app)
            .get("/")
            .expect(200)
            .end((err, res) => {
                if (err) throw err;
            });
    });

    it("GET /aws - success", async () => {
        await request(app)
            .get("/aws")
            .expect(200)
            .end((err, res) => {
                if (err) throw err;
            });
    });

    it("GET /docker - success", async () => {
        await request(app)
            .get("/docker")
            .expect(200)
            .end((err, res) => {
                if (err) throw err;
            });
    });

    it("GET /loadballence - success", async () => {
        await request(app)
            .get("/loadballence")
            .expect(200)
            .end((err, res) => {
                if (err) throw err;
            });
    });

    it("GET /tls - success", async () => {
        await request(app)
            .get("/tls")
            .expect(200)
            .end((err, res) => {
                if (err) throw err;
            });
    });

    it("GET /secret_word - success", async () => {
        await request(app)
            .get("/secret_word")
            .expect(200)
            .end((err, res) => {
                if (err) throw err;
            });
    });

});
