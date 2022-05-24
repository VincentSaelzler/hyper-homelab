#!/usr/bin/env node

const express = require('express')
const app = express()
const port = "{{ port }}"
const myhost = "{{ ansible_host }}"

app.get('/', (req, res) => {
  res.send(`Hello from port ${port} on host ${myhost}`)
})

app.get('/collatz', (req, res) => {
  res.send(`Greetings integer fans from ${port} on host ${myhost}`)
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
