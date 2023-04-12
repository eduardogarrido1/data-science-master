// Definición de las constantes del universo
const altura = 500
const anchura = 800
const margen = {superior: 10, inferior: 70, izquierdo: 70, derecho: 10}

// Definición SVG
const svg = d3.select("#PracticaFinal").append("svg").attr("height", altura).attr("width", anchura)

// Definición Espacio de Trabajo y grupos pertinentes
const EspacioTrabajo = svg.append("g").attr("id", "EspacioTrabajo").attr("transform", `translate(${margen.izquierdo}, ${margen.superior})`)
const GrupoEjes = svg.append("g").attr("id", "GrupoEjes")
const GrupoEjeX = GrupoEjes.append("g").attr("id", "GrupoEjeX").attr("transform", `translate(${margen.izquierdo}, ${altura - margen.inferior})`)
const GrupoEjeY = GrupoEjes.append("g").attr("id", "GrupoEjeY").attr("transform", `translate(${margen.izquierdo}, ${margen.superior})`)

// Definición de los Rangos (Escalas)
const RangoX = d3.scaleLinear().range([0, anchura - margen.izquierdo - margen.derecho])
const RangoY = d3.scaleBand().range([altura - margen.superior - margen.inferior, 0]).padding(0.1)

// Definición de los ejes
const EjeX = d3.axisBottom().scale(RangoX)
const EjeY = d3.axisLeft().scale(RangoY)

// Importación de data
d3.csv("data.csv").then(data => {
    console.log(data)

    // Transformación de datos
    data.map(d => {
        d.year = +d.year
    })

    // Agrupación de datos
    data = d3.nest()
        .key(d => d.winner)
        .entries(data)
    
    // Limpieza de data
    .filter(d => d.key != "")

    // Definición de los Dominios
    const x = RangoX.domain([0, d3.max(data.map(d => d.values)).length])
    const y = RangoY.domain(data.map(d => d.key))

    // Dibujo de los ejes
    GrupoEjeX.call(EjeX)
    GrupoEjeY.call(EjeY)

    // Dibujo condicionado de los valores en la gráfica
    EspacioTrabajo.selectAll("rect").data(data)
        .join("rect")
        //.filter(d => {return d.key != ""})
            .attr("x", 0)
            .attr("y", (d, i) => RangoY(d.key))
            .attr("width", d => RangoX(d.values.length))
            .attr("height", RangoY.bandwidth())
            .attr("class", d => RangoX(d.values.length) == 720 ? true : false)
            .attr("stroke", "black")
})