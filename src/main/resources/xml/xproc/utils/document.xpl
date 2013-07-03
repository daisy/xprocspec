<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step name="main" type="pxi:document" xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0" xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc-internal/xprocspec" exclude-inline-prefixes="#all"
    xpath-version="2.0" xmlns:x="http://www.daisy.org/ns/pipeline/xproc/test">

    <p:input port="document" primary="true"/>
    <p:input port="description"/>
    <p:output port="result" sequence="true"/>
    
    <p:import href="../utils/load.xpl"/>
    <p:import href="../utils/recursive-directory-list.xpl"/>
    <p:import href="../utils/logging-library.xpl"/>
    
    <p:variable name="type" select="/*/@type"/>
    
    <p:variable name="temp-dir" select="/*/@temp-dir">
        <p:pipe port="description" step="main"/>
    </p:variable>
    <p:variable name="base-uri" select="if (/*/@base-uri=('temp-dir')) then /*/@base-uri else ''"/>
    <p:variable name="base-dir" select="if ($base-uri='temp-dir') then $temp-dir else replace(base-uri(/*),'^(.*/)[^/]*$','$1')"/>
    
    <p:variable name="port" select="/*/@port"/>
    <p:variable name="file" select="resolve-uri(/*/@file, $base-dir)"/>
    <p:variable name="method" select="if (/*/@method=('xml','html','text','binary')) then /*/@method else 'xml'"/>
    <p:variable name="directory" select="resolve-uri(/*/@directory, $base-dir)"/>
    <p:variable name="recursive" select="if (/*/@recursive=('true','false')) then /*/@recursive else 'false'"/>
    
    
    <p:identity>
        <p:input port="source">
            <p:pipe step="main" port="description"/>
        </p:input>
    </p:identity>
    <p:choose>
        <p:when test="/*/@type='inline'">
            <p:variable name="base" select="resolve-uri((/*/@xml:base,base-uri())[1],$base-dir)"/>
            <p:for-each>
                <p:iteration-source select="/*/*"/>
                <!-- set base URI of result -->
                <p:choose>
                    <p:when test="/*/@xml:base">
                        <p:add-attribute match="/*" attribute-name="xml:base">
                            <!-- in case xml:base is relative -->
                            <p:with-option name="attribute-value" select="resolve-uri(/*/@xml:base,$base)"/>
                        </p:add-attribute>
                    </p:when>
                    <p:otherwise>
                        <p:add-attribute match="/*" attribute-name="xml:base">
                            <p:with-option name="attribute-value" select="$base"/>
                        </p:add-attribute>
                        <p:delete match="/*/@xml:base"/>
                    </p:otherwise>
                </p:choose>
            </p:for-each>
        </p:when>
        
        <p:when test="/*/@type='port'">
            <p:variable name="position" select="if ($position=('all','last') or matches($position,'\d+')) then $position else 'all'"/>
            <p:filter>
                <p:with-option name="select" select="concat('/x:description/x:output[@port=&quot;',$port,'&quot;]/x:document')"/>
            </p:filter>
            <p:for-each>
                <p:iteration-source select="/*/*"/>
                <p:identity/>
            </p:for-each>
            <p:choose>
                <p:xpath-context>
                    <p:inline>
                        <doc/>
                    </p:inline>
                </p:xpath-context>
                <p:when test="$position='all'">
                    <p:identity/>
                </p:when>
                <p:otherwise>
                    <p:split-sequence initial-only="true">
                        <p:with-option name="test" select="concat('position()=',(if ($position='last') then 'last()' else $position))"/>
                    </p:split-sequence>
                </p:otherwise>
            </p:choose>
        </p:when>
        
        <p:when test="/*/@type='file'">
            <pxi:load>
                <p:with-option name="href" select="$file"/>
                <p:with-option name="method" select="$method"/>
            </pxi:load>
        </p:when>
        
        <p:when test="/*/@type='directory'">
            <pxi:directory-list>
                <p:with-option name="path" select="$directory"/>
                <p:with-option name="depth" select="if ($recursive='true') then '-1' else '0'"/>
            </pxi:directory-list>
            <p:delete match="//*/@xml:base"/>
        </p:when>
        
        <p:when test="/*/@type='errors'">
            <p:for-each>
                <p:iteration-source select="/x:description/c:errors"/>
                <p:identity/>
            </p:for-each>
        </p:when>
    </p:choose>

</p:declare-step>
