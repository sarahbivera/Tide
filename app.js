// 1) Import ONLY the Firebase pieces we use, straight from the CDN.
//    No build tools, no npm install for the app itself — just a browser.
import { initializeApp } from "https://www.gstatic.com/firebasejs/12.15.0/firebase-app.js";
import {
  getAuth, createUserWithEmailAndPassword,
  signInWithEmailAndPassword, signOut, onAuthStateChanged
} from "https://www.gstatic.com/firebasejs/12.15.0/firebase-auth.js";
import {
  getFirestore, collection, addDoc, onSnapshot, query,
  where, orderBy, doc, updateDoc, deleteDoc, serverTimestamp
} from "https://www.gstatic.com/firebasejs/12.15.0/firebase-firestore.js";

// 2) Your project config. Copy it from the Firebase console:
//    Project settings (gear) -> Your apps -> SDK setup and configuration.
const firebaseConfig = {
  apiKey: "AIzaSyDLRAvYkHToPxT7guTdDdu-oFBiLPqwWuk",
  authDomain: "tide-af8b5.firebaseapp.com",
  projectId: "tide-af8b5",
  appId: "1:239752060846:web:88fb93cea2c38326eb323f",
};

// 3) Start Firebase, then grab the Auth and Firestore handles.
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

const $ = (id) => document.getElementById(id);
const authError = $("authError");

// ---- AUTH: the three buttons ----
$("signupBtn").onclick = async () => {
  authError.textContent = "";
  try {
    await createUserWithEmailAndPassword(auth, $("email").value, $("password").value);
  } catch (e) { authError.textContent = pretty(e.code); }
};
$("signinBtn").onclick = async () => {
  authError.textContent = "";
  try {
    await signInWithEmailAndPassword(auth, $("email").value, $("password").value);
  } catch (e) { authError.textContent = pretty(e.code); }
};
$("signoutBtn").onclick = () => signOut(auth);

function pretty(code) {
  if (code === "auth/invalid-credential")   return "Wrong email or password.";
  if (code === "auth/email-already-in-use") return "That email is already registered.";
  if (code === "auth/weak-password")        return "Password needs 6+ characters.";
  return "Error: " + code;
}

// ---- AUTH STATE: fires on login/logout. Picks the view + starts the list. ----
let unsubscribe = null;
onAuthStateChanged(auth, (user) => {
  if (user) {
    $("auth").hidden = true;
    $("app").hidden = false;
    $("who").textContent = user.email;
    watchTasks(user.uid);
  } else {
    $("app").hidden = true;
    $("auth").hidden = false;
    if (unsubscribe) unsubscribe();
    $("list").innerHTML = "";
  }
});

// ---- CREATE: add a task (ownerId ties it to the signed-in user) ----
$("addForm").addEventListener("submit", async (e) => {
  e.preventDefault();
  const title = $("taskTitle").value.trim();
  if (!title) return;
  await addDoc(collection(db, "tasks"), {
    title: title,
    done: false,
    ownerId: auth.currentUser.uid,
    createdAt: serverTimestamp(),
  });
  $("taskTitle").value = "";
});

// ---- REAL-TIME READ: live list that redraws on EVERY change ----
function watchTasks(uid) {
  const q = query(
    collection(db, "tasks"),
    where("ownerId", "==", uid),
    orderBy("createdAt", "desc")
  );
  unsubscribe = onSnapshot(q, (snap) => {
    const list = $("list");
    list.innerHTML = "";
    snap.forEach((d) => list.appendChild(row(d.id, d.data())));
  });
}

// build one <li> with a checkbox (update) and a delete button
function row(id, t) {
  const li = document.createElement("li");
  if (t.done) li.className = "done";
  const cb = document.createElement("input");
  cb.type = "checkbox"; cb.checked = t.done;
  cb.onchange = () => updateDoc(doc(db, "tasks", id), { done: cb.checked });
  const span = document.createElement("span");
  span.textContent = t.title;
  const del = document.createElement("button");
  del.textContent = "✕"; del.className = "del";
  del.onclick = () => deleteDoc(doc(db, "tasks", id));
  li.append(cb, span, del);
  return li;
}
