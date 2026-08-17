const request = require("supertest");
const app = require("../app");

describe("GET /api/health", () => {
  it("returns healthy status", async () => {
    const response = await request(app).get("/api/health");

    expect(response.statusCode).toBe(200);
    expect(response.body.status).toBe("healthy");
    expect(response.body.service).toBe("farmdirect-backend");
    expect(response.body.timestamp).toBeDefined();
  });
});