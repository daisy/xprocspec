<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:x="http://www.daisy.org/ns/xprocspec"
    exclude-result-prefixes="#all"
    version="2.0">
    <xsl:variable name="alternate" select="collection()[2]"/>
    <xsl:variable name="ignore-nodes" select="x:ignore-node-paths($alternate)"/>

    <xsl:key name="node-path" match="@* | node()" use="x:path(.)"/>
    
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="key('node-path', $ignore-nodes)">
        <xsl:choose>
            <xsl:when test="self::text()">
                <xsl:text>...</xsl:text>
            </xsl:when>
            <xsl:when test="self::element()">
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                    <xsl:text>...</xsl:text>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="self::attribute()">
                <xsl:attribute name="{name()}" select="'...'" namespace="{namespace-uri()}"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:function name="x:ignore-node-paths" as="xs:string*">
        <xsl:param name="alternate" as="document-node()"/>
        <xsl:variable name="ignore-text" select="$alternate//text()[. = '...']"/>
        <xsl:variable name="ignore-text" select="$ignore-text / x:path(parent::*)"/>
        <xsl:variable name="ignore-attr" select="$alternate//@*[. = '...']/x:path(.)"/>
        
        <xsl:sequence select="$ignore-text, $ignore-attr"/>
        
    </xsl:function>
    
    <xsl:function name="x:path" as="xs:string">
        <xsl:param name="node" as="node()"/>
        <xsl:variable name="parent-path" select="
            if ($node instance of document-node()) then '' else x:path($node/parent::node())
            "/>
        <xsl:variable name="node-name" select="x:node-name($node)"/>
        <xsl:variable name="node-position" select="
            count($node/preceding-sibling::node()[x:node-name(.) = $node-name]) + 1
            "/>
        <xsl:variable name="predicate" select="
            if ($node instance of attribute()) then '' else concat('[', $node-position, ']')
            "/>
        
        <xsl:sequence select="concat($parent-path, '/', $node-name, $predicate)"/>
    </xsl:function>
    
    <xsl:function name="x:node-name" as="xs:string">
        <xsl:param name="node" as="node()"/>
        
        <xsl:variable name="namespace" select="$node/namespace-uri()"/>
        <xsl:variable name="name" select="concat('Q{', $namespace, '}', local-name($node))"/>
        
        <xsl:sequence select="
                 if ($node instance of text()) 
               then 'text()' 
            else if ($node instance of comment()) 
               then 'comment()' 
            else if ($node instance of processing-instruction()) 
               then 'processing-instruction()' 
            else if ($node instance of document-node()) 
               then '' 
            else if ($node instance of element()) 
               then $name 
            else if ($node instance of attribute() and $namespace = '') 
               then local-name($node) 
            else if ($node instance of attribute()) 
               then $name 
               else ''
            "/>
        
    </xsl:function>
    
</xsl:stylesheet>