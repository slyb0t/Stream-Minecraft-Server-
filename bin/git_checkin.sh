BRANCH=$(git rev-parse --abbrev-ref HEAD)

function main(){
  cd /home/betty
  git status
  git add /home/betty/world/ /home/betty/world_nether/ /home/betty/world_the_end/

  if [ "${BRANCH}" !== "main" ]; then
    echo "using branch ${BRANCH}"
    git commit -m 'updates from the minecraft serv3er'
    git push origin ${BRANCH}
else
  echo "Create a new branch first" 
fi
}

main "$@"
