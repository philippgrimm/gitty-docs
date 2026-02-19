#!/usr/bin/env bash
# setup-test-repo.sh
# Creates a sample git repository for gitty screenshot capture.
# Idempotent: safe to re-run.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)/test-repo"

echo "Setting up test repo at: $REPO_DIR"

# --- Idempotent: remove existing repo ---
if [ -d "$REPO_DIR" ]; then
  echo "Removing existing test-repo..."
  rm -rf "$REPO_DIR"
fi

mkdir -p "$REPO_DIR"
cd "$REPO_DIR"

git init
git config user.email "dev@example.com"
git config user.name "Dev User"

# ─── Helper ───────────────────────────────────────────────────────────────────
commit() {
  git add -A
  git commit -m "$1"
}

# ─── Initial files ────────────────────────────────────────────────────────────
cat > README.md << 'EOF'
# MyApp

A simple web application.

## Setup

```bash
composer install
npm install
```

## Usage

Visit `http://localhost:8080` after starting the server.
EOF

cat > config.json << 'EOF'
{
  "app": {
    "name": "MyApp",
    "version": "1.0.0",
    "debug": false,
    "port": 8080
  },
  "database": {
    "host": "localhost",
    "port": 3306,
    "name": "myapp_db"
  }
}
EOF

commit "Initial commit"

# ─── Add PHP file ─────────────────────────────────────────────────────────────
cat > index.php << 'EOF'
<?php
declare(strict_types=1);

require_once __DIR__ . '/vendor/autoload.php';

use App\Router;
use App\Config;

$config = Config::load(__DIR__ . '/config.json');
$router = new Router($config);

$router->get('/', function () {
    include __DIR__ . '/views/home.php';
});

$router->get('/login', function () {
    include __DIR__ . '/views/login.php';
});

$router->run();
EOF

commit "feat: add entry point with router"

# ─── Add JS file ──────────────────────────────────────────────────────────────
cat > app.js << 'EOF'
'use strict';

const App = (() => {
  const API_BASE = '/api/v1';

  async function fetchUser(id) {
    const res = await fetch(`${API_BASE}/users/${id}`);
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    return res.json();
  }

  function renderUser(user) {
    const el = document.getElementById('user-card');
    el.innerHTML = `<h2>${user.name}</h2><p>${user.email}</p>`;
  }

  function init() {
    document.addEventListener('DOMContentLoaded', () => {
      const userId = document.body.dataset.userId;
      if (userId) {
        fetchUser(userId).then(renderUser).catch(console.error);
      }
    });
  }

  return { init };
})();

App.init();
EOF

commit "feat: add frontend app module"

# ─── Add CSS file ─────────────────────────────────────────────────────────────
cat > style.css << 'EOF'
/* Base reset */
*, *::before, *::after {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

:root {
  --color-primary: #4f46e5;
  --color-secondary: #7c3aed;
  --color-bg: #f9fafb;
  --color-text: #111827;
  --radius: 0.5rem;
}

body {
  font-family: system-ui, sans-serif;
  background: var(--color-bg);
  color: var(--color-text);
  line-height: 1.6;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 1rem;
}

.btn {
  display: inline-flex;
  align-items: center;
  padding: 0.5rem 1rem;
  border-radius: var(--radius);
  background: var(--color-primary);
  color: #fff;
  font-weight: 600;
  cursor: pointer;
  border: none;
  transition: background 0.2s;
}

.btn:hover {
  background: var(--color-secondary);
}

#user-card {
  padding: 1rem;
  border: 1px solid #e5e7eb;
  border-radius: var(--radius);
  background: #fff;
}
EOF

commit "feat: add base stylesheet"

# ─── Auth feature branch ──────────────────────────────────────────────────────
git checkout -b feature/auth

cat > auth.php << 'EOF'
<?php
declare(strict_types=1);

namespace App;

class Auth
{
    private array $config;

    public function __construct(array $config)
    {
        $this->config = $config;
    }

    public function login(string $username, string $password): bool
    {
        // TODO: replace with real DB lookup
        $hash = password_hash('secret', PASSWORD_BCRYPT);
        return password_verify($password, $hash);
    }

    public function logout(): void
    {
        session_destroy();
    }

    public function isAuthenticated(): bool
    {
        return isset($_SESSION['user_id']);
    }
}
EOF

commit "feat(auth): add Auth class"

cat > login.php << 'EOF'
<?php
declare(strict_types=1);

use App\Auth;

$auth = new Auth($config);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = $_POST['username'] ?? '';
    $password = $_POST['password'] ?? '';

    if ($auth->login($username, $password)) {
        $_SESSION['user_id'] = $username;
        header('Location: /dashboard');
        exit;
    }

    $error = 'Invalid credentials';
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Login – MyApp</title>
  <link rel="stylesheet" href="/style.css">
</head>
<body>
  <div class="container">
    <h1>Login</h1>
    <?php if (!empty($error)): ?>
      <p class="error"><?= htmlspecialchars($error) ?></p>
    <?php endif; ?>
    <form method="post">
      <input type="text" name="username" placeholder="Username" required>
      <input type="password" name="password" placeholder="Password" required>
      <button class="btn" type="submit">Sign in</button>
    </form>
  </div>
</body>
</html>
EOF

commit "feat(auth): add login page"

cat >> app.js << 'EOF'

// Auth helpers
const Auth = {
  async login(username, password) {
    const res = await fetch('/api/v1/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ username, password }),
    });
    return res.json();
  },

  logout() {
    return fetch('/api/v1/logout', { method: 'POST' });
  },
};
EOF

commit "feat(auth): add client-side auth helpers"

# ─── Merge feature/auth into main ─────────────────────────────────────────────
git checkout main
git merge --no-ff feature/auth -m "Merge branch 'feature/auth' into main"

# ─── Bugfix branch ────────────────────────────────────────────────────────────
git checkout -b bugfix/login-error

# Fix login redirect
sed -i.bak "s|header('Location: /dashboard');|header('Location: /?welcome=1');|" login.php
rm -f login.php.bak
commit "fix(auth): correct post-login redirect to home"

# Fix CSS error style
cat >> style.css << 'EOF'

.error {
  color: #dc2626;
  background: #fee2e2;
  padding: 0.5rem 1rem;
  border-radius: var(--radius);
  margin-bottom: 1rem;
}
EOF
commit "fix: add missing error style"

git checkout main
git merge --no-ff bugfix/login-error -m "Merge branch 'bugfix/login-error' into main"

# ─── A few more commits on main ───────────────────────────────────────────────
cat >> README.md << 'EOF'

## Authentication

Users can log in at `/login`. Sessions are managed server-side.
EOF
commit "docs: document authentication flow"

cat > config.json << 'EOF'
{
  "app": {
    "name": "MyApp",
    "version": "1.1.0",
    "debug": false,
    "port": 8080
  },
  "database": {
    "host": "localhost",
    "port": 3306,
    "name": "myapp_db"
  },
  "session": {
    "lifetime": 3600,
    "secure": true
  }
}
EOF
commit "chore: bump version to 1.1.0, add session config"

# ─── Stash entry ──────────────────────────────────────────────────────────────
cat > wip-feature.js << 'EOF'
// Work in progress: notification system
const Notifications = {
  show(msg, type = 'info') {
    console.log(`[${type}] ${msg}`);
  },
};
EOF
git add wip-feature.js
git stash push -m "wip: notification system draft"

# ─── Staged changes ───────────────────────────────────────────────────────────
# Modify index.php and stage it
cat >> index.php << 'EOF'

// Maintenance mode check
if (getenv('MAINTENANCE') === 'true') {
    http_response_code(503);
    echo '<h1>Under Maintenance</h1>';
    exit;
}
EOF
git add index.php

# Modify style.css and stage it
cat >> style.css << 'EOF'

/* Dark mode */
@media (prefers-color-scheme: dark) {
  :root {
    --color-bg: #111827;
    --color-text: #f9fafb;
  }
}
EOF
git add style.css

# ─── Unstaged modifications ───────────────────────────────────────────────────
# Modify app.js without staging
cat >> app.js << 'EOF'

// TODO: add WebSocket support
// const ws = new WebSocket('ws://localhost:8080/ws');
EOF

# Modify README.md without staging
cat >> README.md << 'EOF'

## Contributing

Pull requests welcome. Please run tests before submitting.
EOF

# ─── Untracked files ──────────────────────────────────────────────────────────
cat > .env.example << 'EOF'
APP_ENV=development
APP_PORT=8080
DB_HOST=localhost
DB_PORT=3306
DB_NAME=myapp_db
EOF

cat > TODO.md << 'EOF'
# TODO

- [ ] Add unit tests
- [ ] Set up CI pipeline
- [ ] Add rate limiting to login endpoint
- [ ] Implement password reset flow
EOF

echo ""
echo "✅ Test repo created at: $REPO_DIR"
echo ""
echo "--- Status ---"
git status
echo ""
echo "--- Log (oneline) ---"
git log --oneline
echo ""
echo "--- Branches ---"
git branch
echo ""
echo "--- Stash ---"
git stash list
