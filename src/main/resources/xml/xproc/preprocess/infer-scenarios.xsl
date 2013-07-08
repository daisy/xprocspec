<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:p="http://www.w3.org/ns/xproc" xmlns:x="http://www.daisy.org/ns/xprocspec" xmlns:c="http://www.w3.org/ns/xproc-step" exclude-result-prefixes="#all">

    <xsl:output indent="yes" method="xml"/>

    <xsl:template match="/x:description">
        <x:descriptions>
            <xsl:for-each select="//x:scenario">
                <xsl:variable name="like" select="x:like"/>
                <xsl:variable name="scenarios" select="ancestor::x:scenario | (for $label in ($like/(@label,normalize-space(x:label))) return //x:scenario[@shared='yes' and (@label,normalize-space(x:label))=$label]) | self::x:scenario"/>
                <x:description>
                    <xsl:copy-of select="/*/@*"/>
                    <xsl:copy>
                        <xsl:copy-of select="$scenarios/@*"/>
                        <xsl:if test="$scenarios[@pending or ancestor::x:pending]">
                            <xsl:attribute name="pending" select="($scenarios[@pending or ancestor::x:pending]/(if (@pending) then @pending else ancestor::x:pending[last()]/@label))[last()]"/>
                        </xsl:if>
                        <xsl:choose>
                            <xsl:when test="@implementation"><!-- TODO --></xsl:when>
                            <xsl:otherwise>
                                <x:call>
                                    <xsl:copy-of select="$scenarios/x:call/@*"/>
                                    <xsl:copy-of select="x:resolve-options($scenarios/x:call/x:option)"/>
                                    <xsl:copy-of select="x:resolve-params($scenarios/x:call/(x:param,document(x:params/resolve-uri(@href,base-uri(/*)))/c:param-set/c:param))"/>
                                    <xsl:copy-of select="x:resolve-inputs($scenarios/x:call/x:input)"/>
                                </x:call>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:copy-of select="$scenarios/(x:context|x:expect)"/>
                    </xsl:copy>
                </x:description>
            </xsl:for-each>
        </x:descriptions>
    </xsl:template>

    <xsl:function name="x:resolve-options">
        <xsl:param name="options"/>
        <xsl:for-each select="distinct-values($options/@name)">
            <xsl:variable name="name" select="."/>
            <xsl:copy-of select="($options[@name=$name])[last()]"/>
        </xsl:for-each>
    </xsl:function>

    <xsl:function name="x:resolve-params">
        <xsl:param name="params"/>
        <xsl:for-each select="distinct-values($params/@name)">
            <xsl:variable name="name" select="."/>
            <xsl:variable name="param" select="($params[@name=$name])[last()]"/>
            <xsl:choose>
                <xsl:when test="$param[self::x:param]">
                    <xsl:copy-of select="$param"/>
                </xsl:when>
                <xsl:otherwise>
                    <x:param name="{$param/@name}" select="concat('&apos;',replace(replace(replace($param/@value,'&amp;','&amp;amp;'),&quot;'&quot;,&quot;&amp;apos;&quot;),'&quot;','&amp;quot;'),'&apos;')">
                        <xsl:if test="$param/@namespace">
                            <xsl:attribute name="ns" select="$param/@namespace"/>
                        </xsl:if>
                    </x:param>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>

    <xsl:function name="x:resolve-inputs">
        <xsl:param name="inputs"/>
        <xsl:for-each select="distinct-values($inputs/@port)">
            <xsl:variable name="port" select="."/>
            <xsl:copy-of select="($inputs[@port=$port])[last()]"/>
        </xsl:for-each>
    </xsl:function>

</xsl:stylesheet>
