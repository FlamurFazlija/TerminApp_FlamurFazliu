<template>
  <div>
    <nav>
      <NuxtLink to="/">Slots</NuxtLink>
      <NuxtLink to="/meine-buchungen">Meine Buchungen</NuxtLink>
      <NuxtLink to="/admin">Admin</NuxtLink>
      <NuxtLink to="/login">Login</NuxtLink>
    </nav>

    <main>
      <NuxtPage />
    </main>
  </div>
</template>

<style>
body {
  margin: 0;
  font-family: Arial, sans-serif;
  background: #f4f4f4;
}

nav {
  background: #1f2937;
  padding: 16px;
  display: flex;
  gap: 20px;
}

nav a {
  color: white;
  text-decoration: none;
  font-weight: bold;
}

main {
  max-width: 900px;
  margin: 30px auto;
  background: white;
  padding: 24px;
  border-radius: 8px;
}
</style>