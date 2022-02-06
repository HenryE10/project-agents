# project-agents

# Agents
Se trabaja sobre una estructura de datos que simula el ambiente que posee un array de posiciones para cada tipo de elemento del ambiente con la particularidad que los niños
y robots además de la posición de cada uno guarda una variable bool que en los niños representa que estos no pueden moverse ya sea por encontrarse en un corral o por estar 
encima de un robot, en los robots significa que el mismo posee un niño encima. 

Primero se genera todo el ambiente, cada método de generar elementos recibe un ambiente y retorna un nuevo ambiente con los nuevos elementos generados. 
Comenzamos con el corral ya que el mismo se genera a partir de una posición que seleccionamos random y se va formando a partir de sus adyacentes hasta que el mismo posea tantas casillas como niños
hay en el ambiente. Para esto realizamos una especie de bfs con un contador de la longitud que debe tener y a partir de su posición inicial vamos incluyendo los adyacentes al corrol y de estos sus adyacentes
hasta alcanzar la longitud deseada.

Luego para generar todos los demás elementos utilizamos dos listas de ramdom una para cada dimensión del tablero y lo que hacemos es ir tomando los valores (x,y) de estas lista y si la posición no se encuentra
ocupada generamos en esta el elemnto que estemos creando, esto sería incluir la posición en el array del ambiente que representa este elemento. De este modo generamos los niños, obstaculos, robots y suciedad todos
con una cantidad inicial determinada. Con todos los elemntos generados el ambiente esta listo para la simulación.

Luego dos elemntos realizan movimientos:
Los niños los cuales pueden en cada turno moverse o no a una posición adyacente para esto tenemos un método que selecciona que niño del ambiente va a moverse y cual no y en caso de moverse hacia que adyacente realiza
su movimiento de ser posible.

Para esto tenemos un método que selecciona los k primeros elementos de una lista de random con valores del 1 al 7 donde k es la cantidad de niños del ambiente. Utilizamos valores del 1 al 7 para que cada niño tenga una
probabolidad del 50% de moverse por tanto los valores 4, 5, 6 y 7 en la posición i representan que paara el i-ésimo niño del ambiente no va a existir movimiento mientras que los valores 0,1,2,3 representan que abrá movimiento
y a su vez hacia cual dirección adyacente intentará moverse.

Una vez generada esta lista la recorremos y por cada niño mandamos a mover en caso de que este vaya a realizar moviemnto hacia una dirección. Si la posición está vacía el movimiento se realiza sin problemas y solo se updatea la posición
nueva por la vieja en el array de niño.
Si la posición esta ocupada por una suciedad, un robot o un corral el niño no realiza movimiento.
En el caso donde la posición a la que intenta moverse este ocupada por un obstaculo el mismo puede mover ese y todos los obstaculos que se encuentren adyacentes en esa dirección por tanto antes de realizar el movimiento tenemos un método que va
revisando los adyacentes en esa dirección y mientras sean posiiciones válidas que contengan un obstaculos los incluye en la lista de esta forma obtendriamos todos los objetos que moveria el niño al desplazarse hacia esa posición. Luego el primer
obstáculo de esta lista sería el ultimo obstaculo que movería el niño por tanto para poder realizar su movimiento la posición adyacente a este en la misma dirección del movimiento tiene que ser una posición válida y a su vez vacía, si no es así el
niño no puede empujar los obstaculos, por tanto no podrá moverse, en caso de que si pueda moverse hacemos update a la posición del niño y a la posición de cada obstaculo que este empuja en el array de obstáculos.

Una vez un niño realice un movimiento el mismo puede ensuciar por tanto se busca la cuadrícula de 3x3 con centro en la posición donde se encontraba el niño antes de moverse y de esta se toman las posiciones vacías estas son las que pueden ser ensuciadas,
luego de igual forma se busca la cantidad de niños de esta cuadrícula ya que de esta depende cuanto ensucia el niño y luego se realiza un random de 0 a la cantidad máxima de casillas a ensuciar. Una vez se obtenga cuantas casillas va a ensuciar el niño(pueden ser 0
y no ensuciar) se van tomando estas de las posiciones vacías previamente calculadas y se van agregando al array de suciedad lo que representa que ahora esta casilla esta sucia. De esta forma termina el movimiento de los niños.

Para nuestros agentes o robots donde creamos dos tipos partimos de una misma base. Si un robot se encuentra en una casilla sucia sin un niño encima el mismo siempre la limpia, de igual forma si se encuentra en una casilla con un niño siempre lo carga y busca llevarlo al corral.
Luego de esta base creamos dos agentes el primero siempre busca encontrar al niño mas cercano, mientras el segundo prioriza limpiar la basura mas cercana. Para ambos realizamos el mismo algoritmo dado la posición de un robot realizamos un bfs por las 4 posiciones adyacentes por 
donde el mismo puede moverse buscando al elemento mas cercano según el tipo de agente la posición que retorne el mínimo valor del bfs es el paso que debe dar el robot para acercarse a su objetivo. Una vez el robot se encuentre cargando un niño realizamos un recorrido bfs para encontrar 
el mínimo camino hasta la posición del corral deseada, en este caso dada la forma de crear nuestro corral siempre lo llevamos al ultimo elemnto posible en el array de corrales esto nos garantiza de cierta forma que un robot no se cree interferencia con los propios niños que va soltando. 

Luego el método run_simulate se encarga de correr la simulación con un tiempo t, una vez alcanzado este tiemponuestro ambiente se genera nuevamente con los mismos valores de elementos, para probar nuestra simulación una vez alcanzado el tiempo t retornamos el ambiente que se encuentra en ese momento.
Nuestro método run_simulate llama dentro de él el tipo de moviemiento que desea según el agente ya sea mov_robot1 o mov_robot2.

Para correr nuestro proyecto basta con correr en una terminal los comandos:
stack build
stack exec Agents-exe


