# How to Deploy Documentation on GitHub

There are three primary ways to host and display these markdown documents on GitHub, ranging from zero-configuration viewing to generating a fully fledged static website.

---

## Option 1: Native GitHub Repository Browsing (Zero Setup)

GitHub automatically compiles and renders markdown (`.md`) files in its web editor with syntax highlighting, tables, and lists.

* **How it works**: Once you commit and push the `developer_docs/` folder to your GitHub repository, any user browsing the repo can click into the folder. GitHub will automatically display `developer_docs/README.md` as the landing index page.
* **Navigation**: The relative file links we set up (e.g., `[Setup Guide](getting_started.md)`) will automatically resolve to the correct GitHub file viewer page.
* **Access Control**: If your repository is private, only developers with repository permissions will be able to view the documents. If the repository is public, anyone can read them.

---

## Option 2: GitHub Pages via `/docs` Folder (Recommended for simple sites)

GitHub Pages is a free hosting service that takes HTML, CSS, and Markdown files directly from a repository and publishes a website.

GitHub allows you to host a website directly from a folder named `docs` in your repository. To set this up:

### 1. Rename the documentation folder
In your local repository root, rename the `developer_docs` folder to `docs`:
```bash
mv developer_docs docs
```

### 2. Update references
Change references pointing to `developer_docs/` in your root `README.md` or `DEVELOPER_TUTORIAL.md` to point to `docs/` instead.

### 3. Enable GitHub Pages in Settings
1. Commit and push your changes to GitHub.
2. Go to your repository on GitHub.
3. Click the **Settings** tab at the top.
4. In the left sidebar under "Code and automation", click **Pages**.
5. Under **Build and deployment**:
   * Source: **Deploy from a branch**.
   * Branch: Choose your main branch (e.g. `main` or `master`) and select the `/docs` folder from the dropdown list.
6. Click **Save**.
7. GitHub will compile the Markdown using its native Jekyll builder. Within 1–2 minutes, your documentation site will be live at `https://<your-username>.github.io/<your-repository-name>/`.

---

## Option 3: Premium Docs Site via Docsify / VitePress (Advanced)

If you want a modern, searchable, sidebar-navigated documentation site without writing HTML, you can use a lightweight static compiler like **Docsify** or **VitePress** hosted via GitHub Pages and GitHub Actions.

### ⚡ Quick Setup with Docsify (No-build static site)
Docsify generates your documentation website on the fly by reading markdown files directly in the browser.

1. **Create an `index.html`** in your `developer_docs/` folder containing the Docsify boot script:
   ```html
   <!DOCTYPE html>
   <html lang="en">
   <head>
     <meta charset="UTF-8">
     <title>Gamify Photography Docs</title>
     <link rel="stylesheet" href="//cdn.jsdelivr.net/npm/docsify@4/lib/themes/vue.css">
   </head>
   <body>
     <div id="app">Loading...</div>
     <script>
       window.$docsify = {
         name: 'Gamify Photography',
         repo: 'https://github.com/your-username/your-repository',
         loadSidebar: true, // Auto-generate sidebar from a _sidebar.md file
         homepage: 'README.md'
       }
     </script>
     <script src="//cdn.jsdelivr.net/npm/docsify@4"></script>
   </body>
   </html>
   ```
2. **Setup a Sidebar**: Create a `_sidebar.md` file listing links to your documents:
   ```markdown
   * [Home](README.md)
   * [Getting Started](getting_started.md)
   * [Architecture & Logic](architecture_and_logic.md)
   * [Debugging Guide](debugging_guide.md)
   * [Changing Features & Pages](changing_features_and_pages.md)
   ```
3. Commit these files, rename the folder to `docs`, and enable **GitHub Pages** pointing to the `/docs` folder as shown in Option 2.
4. Docsify will render a professional website with an interactive left sidebar!
