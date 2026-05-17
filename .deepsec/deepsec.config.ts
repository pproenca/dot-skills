import { defineConfig } from "deepsec/config";

export default defineConfig({
  projects: [
    { id: "dot-skills", root: ".." },
    // <deepsec:projects-insert-above>
  ],
});
