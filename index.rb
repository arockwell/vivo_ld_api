#!/usrbin/ruby

require 'rubygems'
require 'sinatra'
require 'net/http'
require 'json'
require 'sparql/client'

SPARQL_QUERY_HEADER = <<-EOH
PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd:   <http://www.w3.org/2001/XMLSchema#>
PREFIX owl:   <http://www.w3.org/2002/07/owl#>
PREFIX swrl:  <http://www.w3.org/2003/11/swrl#>
PREFIX swrlb: <http://www.w3.org/2003/11/swrlb#>
PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
PREFIX bibo: <http://purl.org/ontology/bibo/>
PREFIX dcelem: <http://purl.org/dc/elements/1.1/>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX event: <http://purl.org/NET/c4dm/event.owl#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX geo: <http://aims.fao.org/aos/geopolitical.owl#>
PREFIX pvs: <http://vivoweb.org/ontology/provenance-support#>
PREFIX ero: <http://purl.obolibrary.org/obo/>
PREFIX scires: <http://vivoweb.org/ontology/scientific-research#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX ufVivo: <http://vivo.ufl.edu/ontology/vivo-ufl/>
PREFIX core: <http://vivoweb.org/ontology/core#>
EOH

apis = [
  {
    :path => 'people',
    :bindings => [:first_name, :last_name],
    :sparql => <<-EOH
select ?first_name ?last_name
where
{
  ?person foaf:firstName ?first_name .
  ?person foaf:lastName ?last_name
}
limit 10
EOH
  }
]

SPARQL_ENDPOINT = 'http://sparql.vivo.ufl.edu/sparql'

def execute_sparql(query)
  query = SPARQL_QUERY_HEADER + query
  sparql = SPARQL::Client.new('http://sparql.vivo.ufl.edu/sparql')
  sparql.query(query)
end

def jsonify(statements, bindings)
  json_results = [ ] 
  statements.each do |statement|
    result = {}
    bindings.each do |binding|
      result[binding] = statement[binding]
    end
    json_results << result
  end
  json_results.to_json
end

get '/service/:api' do
  result = ""
  apis.each do |api|
    if api[:path] == params[:api]
      result = "Matched: people!\n"
      result = execute_sparql(api[:sparql])
      result = jsonify(result, api[:bindings])
    else
      result = 'If I knew what I was doing, this would be a 404 page.'
    end
  end
  result
end
