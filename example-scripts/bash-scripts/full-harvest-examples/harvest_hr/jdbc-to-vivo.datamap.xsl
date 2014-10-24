<!--
  Copyright (c) 2010-2011 VIVO Harvester Team. For full list of contributors, please see the AUTHORS file provided.
  All rights reserved.
  This program and the accompanying materials are made available under the terms of the new BSD license which accompanies this distribution, and is available at http://www.opensource.org/licenses/bsd-license.html
-->
<!-- <?xml version="1.0"?> -->
<!-- Header information for the Style Sheet
	The style sheet requires xmlns for each prefix you use in constructing
	the new elements
-->
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:core="http://vivoweb.org/ontology/core#"
	xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:localVivo="http://vivo.sample.edu/ontology/"
	xmlns:db-staff="http://vivo.example.com/harvest/example/jdbc/fields/staff/"
	xmlns:db-positions="http://vivo.example.com/harvest/example/jdbc/fields/positions/"
	xmlns:db-organizations="http://vivo.example.com/harvest/example/jdbc/fields/organizations/"
	xmlns:score='http://vivoweb.org/ontology/score#'
	xmlns:bibo='http://purl.org/ontology/bibo/'
	xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#'>
  
  <!-- This will create indenting in xml readers -->
	<xsl:output method="xml" indent="yes"/>
	<xsl:variable name="baseURI">http://vivoweb.org/harvest/example/jdbc/</xsl:variable>

	<!-- The main node of the record loaded 
		This serves as the header of the RDF file produced
	 -->
	<xsl:template match="rdf:RDF">
		<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:vitro="http://vitro.mannlib.cornell.edu/ns/vitro/public#"
			xmlns:localVivo="http://vivo.sample.edu/ontology/"
			xmlns:foaf="http://xmlns.com/foaf/0.1/"
			xmlns:owl="http://www.w3.org/2002/07/owl#"
			xmlns:core="http://vivoweb.org/ontology/core#"
			xmlns:score="http://vivoweb.org/ontology/score#"
			xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" >
			<xsl:apply-templates select="rdf:Description" />
		</rdf:RDF>
	</xsl:template>
	
	<xsl:template match="rdf:Description">
		<xsl:variable name="this" select="." />
		<xsl:variable name="table">
			<xsl:analyze-string select="../@xml:base" regex="^.*/([^/]+?)$">
				<xsl:matching-substring>
					<xsl:value-of select="regex-group(1)" />
				</xsl:matching-substring>
			</xsl:analyze-string>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$table = 'staff'">
				<xsl:call-template name="staff">
					<xsl:with-param name="this" select="$this" />
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="staff">
		<xsl:param name='this' />
    <xsl:variable name="uid" select="$this/db-staff:UID"/>
		<rdf:Description rdf:about="{$baseURI}staff/uid{$uid}">
			<localVivo:uId rdf:datatype="http://www.w3.org/2001/XMLSchema#string"><xsl:value-of select="$uid"/></localVivo:uId>
			<localVivo:harvestedBy>Example.JDBCFetch-Harvester</localVivo:harvestedBy>
      <rdf:type rdf:resource="http://vivoweb.org/ontology/core#FacultyMember"/>
      <core:email><xsl:value-of select="$this/db-staff:EMAIL" /></core:email>
			<xsl:if test="normalize-space( $this/db-staff:PHONE )">
				<core:phoneNumber><xsl:value-of select="$this/db-staff:PHONE"/></core:phoneNumber>
			</xsl:if>
			<xsl:if test="normalize-space( $this/db-staff:FNAME )">
				<foaf:firstName><xsl:value-of select="$this/db-staff:FNAME"/></foaf:firstName>
			</xsl:if>
			<xsl:if test="normalize-space( $this/db-staff:LNAME )">
				<foaf:lastName><xsl:value-of select="$this/db-staff:LNAME"/></foaf:lastName>
      </xsl:if>
      <rdfs:label><xsl:value-of select="concat($this/db-staff:FNAME, ' ', $this/db-staff:LNAME)"/></rdfs:label>
		</rdf:Description>
	</xsl:template>
	
</xsl:stylesheet>
