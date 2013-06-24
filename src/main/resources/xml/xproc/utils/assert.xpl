<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pxi:assert" name="main" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:p="http://www.w3.org/ns/xproc" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:x="http://www.emc.com/documentum/xml/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc-internal/xprocspec" xmlns:d="http://www.daisy.org/ns/pipeline/data" exclude-inline-prefixes="#all" version="1.0">
    
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p>Example usage:</p>
        <pre xml:space="preserve">
            &lt;px:assert message="All d:file elements must have a media-type attribute. $1 and $2 more d:file elements is missing their media-type attribute." severity="ERROR" error-code="pxe:PEOU0002"&gt;
               &lt;p:with-param name="param1" select="(/d:fileset/d:file[not(@media-type)])[1]/@href"/&gt;
               &lt;p:with-param name="param2" select="count(/d:fileset/d:file[not(@media-type)])-1"/&gt;
           &lt;/px:assert&gt;
        </pre>
    </p:documentation>
    
    <p:input port="source" primary="true" sequence="true">
        <p:empty/>
    </p:input>
    <p:output port="result" sequence="true">
        <p:pipe port="result" step="result"/>
    </p:output>
    
    <p:option name="test" required="true"/>                                         <!-- boolean -->
    <p:option name="error-code" select="''"/>                                       <!-- QName - if not given, only a warning will be displayed. -->
    <p:option name="error-code-prefix" select="''"/>                                <!-- NCName -->
    <p:option name="error-code-namespace" select="''"/>                             <!-- anyURI -->
    <p:option name="message" required="true"/>                                      <!-- description of what you are asserting. $1, $2 etc will be replaced with the contents of param1, param2 etc. -->
    <p:option name="param1" select="''"/>
    <p:option name="param2" select="''"/>
    <p:option name="param3" select="''"/>
    <p:option name="param4" select="''"/>
    <p:option name="param5" select="''"/>
    <p:option name="param6" select="''"/>
    <p:option name="param7" select="''"/>
    <p:option name="param8" select="''"/>
    <p:option name="param9" select="''"/>
    <!-- in the unlikely event that you need more parameters you'll have to format the message string yourself -->
    
    <p:import href="message.xpl"/>
    <p:import href="error.xpl"/>
    
    <p:add-attribute match="/*" attribute-name="message" name="message">
        <p:input port="source">
            <p:inline>
                <c:result/>
            </p:inline>
        </p:input>
        <p:with-option name="attribute-value" use-when="p:system-property('p:xpath-version')='1.0'" select="$message">
            <!-- replace(...) not supported in XPath 1.0 -->
            <p:inline>
                <irrelevant/>
            </p:inline>
        </p:with-option>
        <p:with-option name="attribute-value" use-when="not(p:system-property('p:xpath-version')='1.0')"
            select="replace(replace(replace(replace(replace(replace(replace(replace(replace($message,'\$1',$param1),'\$2',$param2),'\$3',$param3),'\$4',$param4),'\$5',$param5),'\$6',$param6),'\$7',$param7),'\$8',$param8),'\$9',$param9)">
            <p:inline>
                <irrelevant/>
            </p:inline>
        </p:with-option>
    </p:add-attribute>
    
    <p:choose>
        <p:when test="$test='true'">
            <!-- assertion passed; do nothing -->
            <p:identity>
                <p:input port="source">
                    <p:pipe port="source" step="main"/>
                </p:input>
            </p:identity>
        </p:when>
        
        <p:when test="not($error-code='')">
            <!-- assertion failed; throw error -->
            <pxi:error>
                <p:with-option name="message" select="/*/@message"/>
                <p:with-option name="code" select="$error-code"/>
                <p:with-option name="code-namespace" select="$error-code-namespace"/>
                <p:with-option name="code-prefix" select="$error-code-prefix"/>
            </pxi:error>
        </p:when>
        
        <p:otherwise>
            <!-- assertion failed; display warning -->
            <pxi:message>
                <p:with-option name="message" select="/*/@message"/>
                <p:with-option name="severity" select="'WARN'"/>
                <p:input port="source">
                    <p:pipe port="source" step="main"/>
                </p:input>
            </pxi:message>
        </p:otherwise>
    </p:choose>
    
    <p:identity name="result"/>
    
</p:declare-step>