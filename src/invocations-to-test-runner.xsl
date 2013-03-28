<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0" xmlns:p="http://www.w3.org/ns/xproc" xmlns:x="http://www.josteinaj.no/ns/xprocspec" xmlns:c="http://www.w3.org/ns/xproc-step" exclude-result-prefixes="#all">

    <xsl:output indent="yes" method="xml"/>

    <xsl:template match="/*">
        <p:declare-step xmlns:p="http://www.w3.org/ns/xproc" type="x:test" name="main" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0" xpath-version="2.0">
            <xsl:namespace name="x" select="'http://www.josteinaj.no/ns/xprocspec'"/>
            <xsl:variable name="tests" select="/*/p:declare-step/tokenize(@type,':')[last()]"/>
            
            <p:output port="result"/>
            
            <xsl:for-each select="$tests">
                <p:import href="{.}.xpl"/>
            </xsl:for-each>
            
            <xsl:for-each select="$tests">
                <xsl:element name="x:{.}">
                    <xsl:attribute name="name" select="."/>
                </xsl:element>
            </xsl:for-each>
            
            <p:wrap-sequence wrapper="x:wrapper">
                <p:input port="source">
                    <xsl:for-each select="$tests">
                        <p:pipe port="result" step="{.}"/>
                    </xsl:for-each>
                </p:input>
            </p:wrap-sequence>
            
        </p:declare-step>
    </xsl:template>

</xsl:stylesheet>
