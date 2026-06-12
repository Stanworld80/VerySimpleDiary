import {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} from "@firebase/rules-unit-testing";
import fs from "fs";

const PROJECT_ID = "stanverysimplediary-dev";
let testEnv;

describe("Firestore Security Rules Tests", () => {
  before(async () => {
    testEnv = await initializeTestEnvironment({
      projectId: PROJECT_ID,
      firestore: {
        rules: fs.readFileSync("../../firestore.rules", "utf8"),
        host: "127.0.0.1",
        port: 8085,
      },
    });
  });

  after(async () => {
    await testEnv.cleanup();
  });

  beforeEach(async () => {
    await testEnv.clearFirestore();
  });

  it("Unauthenticated read/write to users collection is denied", async () => {
    const unauthenticatedDb = testEnv.unauthenticatedContext().firestore();
    const docRef = unauthenticatedDb.collection("users").doc("test_user");
    
    await assertFails(docRef.get());
    await assertFails(docRef.set({ name: "Stan" }));
  });

  it("Authenticated user can read and write their own documents", async () => {
    const authenticatedDb = testEnv.authenticatedContext("alice").firestore();
    const docRef = authenticatedDb
      .collection("users")
      .doc("alice")
      .collection("diary")
      .doc("2026-06-12");

    await assertSucceeds(docRef.set({ score: 1.5 }));
    await assertSucceeds(docRef.get());
  });

  it("Authenticated user cannot read or write other users documents", async () => {
    const authenticatedDb = testEnv.authenticatedContext("alice").firestore();
    const docRef = authenticatedDb
      .collection("users")
      .doc("bob")
      .collection("diary")
      .doc("2026-06-12");

    await assertFails(docRef.set({ score: 1.5 }));
    await assertFails(docRef.get());
  });
});
