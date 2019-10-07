require 'pry'
require 'pry-byebug'
require 'json'

repos = `curl http://hub.supercanal.tv:5000/v2/_catalog --silent`
repos = JSON.parse(repos)
puts "Listado de Repositorios"
puts ""
i = 1
repos["repositories"].each do |repo|
  puts  "#{i} " + repo
  print "  Tamaño: "
  variable = `docker-compose exec registry du -sh /data/docker/registry/v2/repositories/#{repo}`
  puts variable
  # curl http://hub.supercanal.tv:5000/v2/alertadvr_web/tags/list
  # du -h /data/docker/registry/v2/repositories/
  i += 1
end

print "Escoja num repo al cual desea marcar para borrado sus tags: "
opcion = gets

puts ""
puts "Tags encontrados"
el_repo = repos["repositories"][opcion.to_i - 1]
tags=`curl --silent http://hub.supercanal.tv:5000/v2/#{el_repo}/tags/list`
tags=JSON.parse(tags)

# binding.pry

tags["tags"].each do |tag|
  sha = `curl -v -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -X GET http://hub.supercanal.tv:5000/v2/#{el_repo}/manifests/#{tag} --silent 2>&1 | grep Docker-Content-Digest | awk '{print ($3)}'`
  sha = sha.split("\r\n")[1]
  puts "* #{sha} #{tag}"

  # Marcando para borrado
  resp_borrado = `curl -v --silent -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -X DELETE http://hub.supercanal.tv:5000/v2/#{el_repo}/manifests/#{sha}`
  `docker-compose exec registry registry garbage-collect /etc/docker/registry/config.yml`

end unless tags["tags"].nil?

# En realidad no borra, pero si saca los tags en http://hub.supercanal.tv:8090/repository/alertadvr_web
# Está bien así. Si despues alguien sube 0.3, lo hace muy muy rapido porque ya lo tiene cacheado.

# TODO:dar la opcion de borrar el tag, para no tener 0.1, 0.2, etc, pero no sabemos como quedaría la consistencia. Lo dejo para investigar.
puts "Tags marcados para borrado. Continúan en disco presentes como una forma de cache. "
puts "Desea eliminar todo el repo del registry? (y/n)"
opcion2 = gets
if opcion2 == "y"
  `docker-compose exec registry rm -rfv /data/docker/registry/v2/repositories/#{el_repo}`
end

puts "Programa terminado"

