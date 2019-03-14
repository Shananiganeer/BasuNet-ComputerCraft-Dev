function fetchPath(repo, path)
  local h, file = http.get(repo..path), fs.open(path, "w")
  if not (h == nil) then
    file.write(h.readAll())
    h.close()
    print("Wrote "..path.." from repo")
  else
    print("Error obtaining: "..path)
  end
  file.close()
end

function fetchPaths(repo, paths)
  for k, path in pairs(paths) do
    fetchPath(repo, path)
  end
end