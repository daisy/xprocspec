<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:x="http://www.daisy.org/ns/pipeline/xproc/test" xmlns:rng="http://relaxng.org/ns/structure/1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0" version="2.0">

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="rng:start"/>
    
    <xsl:template match="rng:ref" name="ref">
        <xsl:param name="ancestors" tunnel="yes"/>
        <xsl:variable name="name" select="@name"/>
        <xsl:if test="not($ancestors=$name)">
            <xsl:apply-templates select="//rng:define[@name=$name]">
                <xsl:with-param name="ancestors" select="($ancestors,$name)" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>

    <xsl:template match="rng:define">
        <xsl:param name="ancestors" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$ancestors=()">
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="node()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="rng:element">
        <xsl:copy>
            <xsl:if test="ancestor::rng:element">
                <xsl:attribute name="x:generated" select="'true'"/>
            </xsl:if>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>


</xsl:stylesheet>
