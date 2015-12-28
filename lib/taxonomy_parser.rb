require "taxonomy_parser/version"
require 'active_support/core_ext/object/blank'
require 'nokogiri'
require 'open-uri'
require 'zip'
require 'pp'

class TaxonomyParser
  PROTEGE_URL = 'http://52.4.82.207:8080/webprotege/download?ontology=cafcdef1-058a-41dd-9c6e-19a0bc297c86'
  CONCEPT_GROUP_IRI = 'http://purl.org/iso25964/skos-thes#ConceptGroup'
  CONCEPT_IRI = 'http://www.w3.org/2004/02/skos/core#Concept'
  MEMBER_OF_IRI = 'http://purl.org/umu/uneskos#memberOf'

  def initialize(resource = PROTEGE_URL)
    @resource = resource

    @concepts = []
    @concept_groups = []
    @xml = extract_xml_from_zip
  end

  def parse
    extract_terms(@concept_groups, CONCEPT_GROUP_IRI)
    extract_terms(@concepts, CONCEPT_IRI)
    pp @concept_groups
    pp @concepts
  end

  private

  def extract_terms(terms, iri)
    terms
    root_node = @xml.xpath("//rdf:Description[@rdf:about='#{iri}']").first
    root_node_hash = extract_node_hash(root_node)
    process_subclass_nodes(root_node_hash) do |node_hash|
      terms.push node_hash
    end
  end

  def process_subclass_nodes(node_hash, current_depth = 1, &block)
    node_hash[:subclass_nodes].each do |child_node|
      next if @max_depth && current_depth > @max_depth
      child_node_hash = extract_node_hash(child_node, node_hash[:path])
      next if child_node_hash[:subject] == node_hash[:subject] # Handle case where class is parent of itself... gotta love Protege!
      yield child_node_hash.reject{ |k| [:subclass_nodes, :subject].include?(k) }
      process_subclass_nodes(child_node_hash, (current_depth + 1), &block)
    end
  end

  def extract_node_hash(node, parent_path = nil)
    label = extract_label(node)
    path = build_path(parent_path, label)
    subject = extract_subject(node)
    concept_groups = extract_concept_groups(node)
    subclass_nodes = extract_subclass_nodes(subject)

    { 
      label: label,
      leaf_node: subclass_nodes.blank?,
      path: path,
      subclass_nodes: subclass_nodes,
      subject: subject,
      concept_groups: concept_groups
    }
  end

  def extract_concept_groups(node)
    member_of_nodes = node.xpath("./rdfs:subClassOf/owl:Restriction[owl:onProperty[@rdf:resource='#{MEMBER_OF_IRI}']]")
    concept_group_subjects = member_of_nodes.map{ |node| node.xpath('./owl:someValuesFrom').first.attr('rdf:resource')}.flatten
    concept_group_nodes = concept_group_subjects.map{ |subject| @xml.xpath("//owl:Class[@rdf:about='#{subject}']")}.flatten
    concept_group_nodes.map{|node| extract_label(node) }
  end

  def extract_label(node)
    node.xpath('./rdfs:label').text
  end

  def build_path(parent_path, label)
    "#{parent_path}/#{label}"
  end

  def extract_subject(node)
    node.attr('rdf:about')
  end

  def extract_subclass_nodes(subject)
    @xml.xpath "//owl:Class[rdfs:subClassOf[@rdf:resource='#{subject}']]"
  end

  def extract_xml_from_zip
    open('temp.zip', 'wb') { |file| file << open(@resource).read }

    content = ''
    Zip::File.open('temp.zip') do |zip_file|
      zip_file.each do |entry|
        content += entry.get_input_stream.read if entry.name.end_with?('.owl')
      end
    end

    File.delete('temp.zip')
    Nokogiri::XML(content)
  end
  
end

 

