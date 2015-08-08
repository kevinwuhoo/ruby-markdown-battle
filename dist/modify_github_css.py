#!/usr/bin/env python

github_modified = open("github_modified.css", 'w')

for line in open("github.css"):

  # line has a selector
  if "{" in line:
    line = line.split(", ")
    line = ["#html " + x for x in line]
    github_modified.write(", ".join(line))


  else:
    github_modified.write(line)


