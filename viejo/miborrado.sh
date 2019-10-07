#!/bin/sh

# Versión modificada de https://github.com/Joxit/docker-registry-ui/issues/77#issuecomment-483873260

# Quitar si se usa bashdb
# set -e

echo Lista de proyectos
curl http://hub.supercanal.tv:5000/v2/alertadvr_web/tags/list
 1621  curl -v --silent -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -X GET http://hub.supercanal.tv:5000/v2/alertadvr_web/manifests/latest 2>&1 | grep Docker-Content-Digest | awk '{print ($3)}'
 1622  curl -v --silent -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -X DELETE http://hub.supercanal.tv:5001/v2/alertadvr_web/manifests/sha256:51a1f41c4d465eb8dc93a9d51c3b610c51e7f4635e2a66eeabf2ec508301c6e9
 1623  curl -v --silent -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -X DELETE http://hub.supercanal.tv:5000/v2/alertadvr_web/manifests/sha256:51a1f41c4d465eb8dc93a9d51c3b610c51e7f4635e2a66eeabf2ec508301c6e9

get_array()
{
    #curl --user ${REG_USER} http://${REGISTRY}/v2/_catalog >list
    echo Trayendo lista de imagenes
    curl http://localhost:8090/v2/_catalog >list
    sed -i -- s#repositories##g list;
    sed -i -- s#\{##g list;
    sed -i -- s#\}##g list;
    sed -i -- s#:##g list;
    sed -i -- s#\\[##g list;
    sed -i -- s#\\]##g list;
    sed -i -- s#\"##g list;
    sed -i -- s#\"##g list;
    sed -i -- s#,#" "#g list;
    ARRAY1=$(cat list)
    echo $ARRAY1
    garbage_collect
}

garbage_collect()
{
    echo Marcando para borrado
    echo sleep 1
    # docker       exec ui-as-proxy_registry_1 registry garbage-collect /etc/docker/registry/config.yml &&
    docker-compose exec registry               registry garbage-collect /etc/docker/registry/config.yml &&
    del_repo 
}

del_repo()
{  
    echo "Borrando fisicamente a los marcados para delete"
    # for i in ${ARRAY1[@]}; do 
    for i in ${ARRAY1}; do 
	# curl --user ${REG_USER} http://${REGISTRY}/v2/$i/tags/list | grep null ;
	curl http://localhost:5000/v2/$i/tags/list | grep null ;
	if [ $? -eq 0 ]; then
	    # docker exec -it ui-as-proxy_registry_1 rm -rf /var/lib/registry/docker/registry/v2/repositories/$i
	    docker-compose exec registry rm -rf /data/docker/registry/v2/repositories/$i
        fi


    done
    echo "Reiniciando Registry"
    docker-compose down
    docker-compose up -d

    # Para examinar, lanzar
    # docker-compose logs -f -t --tail=200
}

echo "Limpieza de imágenes marcadas para borrarse"
echo "(2019) Copyleft Sergio Alonso"
date
get_array


