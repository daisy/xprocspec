<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:p="http://www.w3.org/ns/xproc" xmlns:x="http://www.daisy.org/ns/xprocspec" xmlns:c="http://www.w3.org/ns/xproc-step" exclude-result-prefixes="#all">

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="p:declare-step | p:pipeline">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="x:type" select="concat('{',namespace-uri-from-QName(resolve-QName(/*/@type,/*)),'}',tokenize(/*/@type,':')[last()])"/>
            <xsl:namespace name="{prefix-from-QName(resolve-QName(/*/@type,/*))}" select="namespace-uri-from-QName(resolve-QName(/*/@type,/*))"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
