<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns="http://www.w3.org/1999/xhtml" xpath-default-namespace="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all"
    xmlns:x="http://www.daisy.org/ns/pipeline/xproc/test" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:p="http://www.w3.org/ns/xproc">

    <xsl:template match="/*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:for-each select="head">
                <xsl:copy>
                    <xsl:copy-of select="@*|node()"/>
                </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="body">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates select="node()"/>
                    <link href="http://netdna.bootstrapcdn.com/twitter-bootstrap/2.3.1/css/bootstrap-combined.min.css" rel="stylesheet"/>
                    <script src="http://code.jquery.com/jquery.js"> </script>
                    <script src="https://google-code-prettify.googlecode.com/svn/loader/run_prettify.js"> </script>
                    <script src="http://netdna.bootstrapcdn.com/twitter-bootstrap/2.3.1/js/bootstrap.min.js"> </script>
                </xsl:copy>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="x:scenario-results">
        <xsl:variable name="declaration" select="./x:description/x:step-declaration/*"/>
        <xsl:variable name="scenario" select="./x:description/x:scenario"/>
        <xsl:variable name="tests" select="./x:test-result"/>
        <xsl:variable name="test-grammar" select="((./x:description|./x:description/c:errors)/@test-grammar)[1]"/>
        <xsl:variable name="test-base-uri" select="((./x:description|./x:description/c:errors)/@test-base-uri)[1]"/>
        <!--<xsl:variable name="scenario-relative-href" select="substring-after($)"></xsl:variable>-->
        <xsl:text>
</xsl:text>
        <section>
            <!--<xsl:copy-of select="./x:description"/>-->
            <xsl:choose>
                <xsl:when test="$test-grammar='XProc Test Suite'">
                    <h2>XProc Test Suite-test</h2>
                </xsl:when>
                <xsl:otherwise>
                    <h2>Step: <xsl:value-of select="$declaration/@type"/></h2>
                    <xsl:if test="$declaration/@type and $declaration/@x:type">
                        <p><small><xsl:value-of select="concat(if (contains($declaration/@type,':')) then concat('xmlns:',tokenize($declaration/@type,':')[1],'=&quot;') else 'xmlns=&quot;', replace($declaration/@x:type,'\{(.*)\}.*','$1'))"/>"</small></p>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:if test="not(./x:test-result/@result='true')">
                <xsl:if test="$scenario/x:call/x:input">
                    <xsl:text>
</xsl:text>
                    <h3>Inputs</h3>
                    <xsl:text>
</xsl:text>
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Port</th>
                                <th>Content summary</th>
                                <xsl:if test="$scenario/x:call/x:input/x:document/@xml:base">
                                    <th>Base URI</th>
                                </xsl:if>
                            </tr>
                        </thead>
                        <tbody>
                            <xsl:for-each select="$scenario/x:call/x:input">
                                <xsl:text>
</xsl:text>
                                <tr>
                                    <xsl:text>
</xsl:text>
                                    <td>
                                        <xsl:value-of select="@port"/>
                                    </td>
                                    <xsl:text>
</xsl:text>
                                    <td>
                                        <xsl:for-each select="*[position() &lt; 5]">
                                            <xsl:value-of
                                                select="concat(
                                            '&lt;',*/local-name(),' xmlns=&quot;',*/namespace-uri(),'&quot;',
                                            if (.[@*]) then ' ...' else '',
                                            if (*/node()) then concat('&gt;...&lt;/',*/local-name(),'&gt;')
                                                        else '/&gt;'
                                            )"/>
                                            <xsl:if test="following-sibling::*">
                                                <br/>
                                            </xsl:if>
                                        </xsl:for-each>
                                        <xsl:if test="count(*) &gt; 5">
                                            <xsl:value-of select="concat('... ',(count(*)-5),' more documents (a total of ',count(*),') ...')"/>
                                        </xsl:if>
                                    </td>
                                    <xsl:if test="$scenario/x:call/x:input/x:document/@xml:base">
                                        <xsl:text>
</xsl:text>
                                        <td>
                                            <xsl:for-each select="*[position() &lt; 5]">
                                                <xsl:value-of select="@xml:base"/>
                                                <xsl:if test="following-sibling::*">
                                                    <br/>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <xsl:if test="count(*) &gt; 5 and parent::*/*/@xml:base">
                                                <xsl:value-of select="'...'"/>
                                            </xsl:if>
                                        </td>
                                    </xsl:if>
                                    <xsl:text>
</xsl:text>
                                </tr>
                            </xsl:for-each>
                            <xsl:text>
</xsl:text>
                        </tbody>
                    </table>
                </xsl:if>

                <xsl:if test="$scenario/x:call/x:option">
                    <xsl:text>
</xsl:text>
                    <h3>Options</h3>
                    <xsl:text>
</xsl:text>
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Value</th>
                            </tr>
                        </thead>
                        <xsl:text>
</xsl:text>
                        <tbody>
                            <xsl:for-each select="$scenario/x:call/x:option">
                                <xsl:text>
</xsl:text>
                                <tr>
                                    <xsl:text>
</xsl:text>
                                    <td>
                                        <xsl:value-of select="@name"/>
                                    </td>
                                    <xsl:text>
</xsl:text>
                                    <td>
                                        <xsl:value-of select="@select"/>
                                    </td>
                                </tr>
                            </xsl:for-each>
                            <xsl:text>
</xsl:text>
                        </tbody>
                    </table>
                </xsl:if>

                <xsl:if test="$scenario/x:call/x:param">
                    <xsl:text>
</xsl:text>
                    <h3>Parameters</h3>
                    <xsl:text>
</xsl:text>
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Value</th>
                            </tr>
                        </thead>
                        <xsl:text>
</xsl:text>
                        <tbody>
                            <xsl:for-each select="$scenario/x:call/x:param">
                                <xsl:text>
</xsl:text>
                                <tr>
                                    <xsl:text>
</xsl:text>
                                    <td>
                                        <xsl:value-of select="@name"/>
                                    </td>
                                    <xsl:text>
</xsl:text>
                                    <td>
                                        <xsl:value-of select="@select"/>
                                    </td>
                                </tr>
                            </xsl:for-each>
                            <xsl:text>
</xsl:text>
                        </tbody>
                    </table>
                </xsl:if>

                <xsl:text>
</xsl:text>
            </xsl:if>

            <h3>Tests</h3>
            <xsl:if test="not($tests)">
                <h4>
                    <img
                        src="data:image/gif;base64,R0lGODlhGAAYAPf/AP///1XPGFnRF1DNGEvLGCC3G0bIGUHGGV7SFyS4GzG+Gii6Giy8Gvr6+mbZGF7TFy2+GjbAGWLVF2PVF1PNA/X19WPWF9/f32HZGFHPGG/mGCS5G8Hxmii8Gm3hGB3SH2DYAgm7CDLAGrq6ulnSFwa6CCi7Gvz8/DzEGSC4G0vNGBy1G2faGDfCGQK5CGnfGOz64TvDGbjtkez55F7HSD69BSW/HPb98LbrkSizC22/ZVHQGfT87V/XAh28HBy3Gxy2Gzm7DDvCGR/GHrnFuVrVGFLRGPf39zTeJE7JAxy+F3G6cyyzCmDYEjvEGVHRGTS7EjG/Gv39/R29HD28BEvMGEPBBG3gGDLUHRK8CFDbGmneGMbKxh7EHbjDuWPXGGDWGOvr6w25E7fashHGFFbQDSS7GzfTHWbfEsrwsr6+vjW7NDTcHpzoYaa/pjm6PJLWcyTCEEa+JoTOdRrOHND1siC8B1rTF0zZGyrXH6vEqjneIzDgH/v7+6a8p2jYFSi9GtXyx0bkHTjWHV7YFFbRGMDAwM7OzjjCJz/dHG3iGEW5HsvLyyzPHWHYBCLCHSOwBVbTGTHAGkzKIDzVG1bTGFbSGTbCGfL77Si7FtXh1D/PGhe9B0HDFGfgGWziFtfX19Xd1F/UF6rmgrG+sjS5DVzVBCG4D2XbCFDmHQq6DFfVGUa+Pju/FGDXCRfAB6PrZyK7IS++Jiy+KGrhGPDw8GG5ZPv++Wi7aSrZH1vTA1K6VFnSBozNgWfHT7nnoxrKGU7LCRjNGx/OHmnNMuPj4xS9Ch+4BmHDOQ/EEUfaG5PFjijQHi3SHYPRZIzYYjrgHhS6GQ++CWTZGBG6E1/WAjHRHZjjZUHDDkfBCV/VGEbJGVfRA1/EQWfFSGbcGEDiHWfbGFzXGELXG1XQGKnrdmXbGEznHTq8B1bKDjC5NGnbETreHtHzuNX2u17WDEC6HCy9GkfEA6jscCjMHlvXGG7kGSm+G2PbByPGHWjcGMbOxdXyxDzUGyW8HP///yH5BAEAAP8ALAAAAAAYABgAAAj/AP8JHCjwljsO82BxqMODoEOHN8qtA1HNEb4eIFC1gfHQYbs/uj4p8nDFgyJ7Gky5ktFRIA5e717oY+GgJotwW2ih4XatYxoKTcx9sTBBgtEJEyxM++aJwiiHM9KVwaDtwQMEWLM+EAUGA6Ek/Ag+k1fvDgkBaNOmJXGniLhgxAZiylbJErkAePPqBQCgUKRVVgIJ/EVlRwYVAxIrVsyXr5EnNeAIdIZORRUCmDNnbsxXiwpsyAR6C2JgmwEDfCedRs05FR4DnRYJ7FbqgG3OtzmfU2a7FTyBvpjEQLGJs3EAgsahcCIEihyBcyBFuNQv0XG+4Ci1aBEhQg4aAsfYwVGgQNIgdsehnREhIgr5Y70E1kJ0igEDCFjYcN5jDQKEePZlEocmAy3zyj0LLGBCM3zwhUQjgHRgQoIdcKJDAwOFwUoWNiSQwAbM5JIHPWZs4GEC/hgjSygO7TNLCPmkUMCMNM6YwiPSKKHHCQ6dQMQaIQAzxBQ/rLACED50MUwIsbhRQUcNcIELNSUkI8wHH9BBRgmq7OLFky1JcQEpS7wRjQsuiKGOLX6A0kdLBDVQzCGGjDCCGoyAcgScfPb5T0AAOw=="
                        alt="Success:"/>
                    No errors occured on step invocation.
                </h4>
            </xsl:if>
            <xsl:for-each select="$tests">
                <xsl:text>
</xsl:text>
                <h4>
                    <xsl:choose>
                        <xsl:when test="@result='true'">
                            <img
                                src="data:image/gif;base64,R0lGODlhGAAYAPf/AP///1XPGFnRF1DNGEvLGCC3G0bIGUHGGV7SFyS4GzG+Gii6Giy8Gvr6+mbZGF7TFy2+GjbAGWLVF2PVF1PNA/X19WPWF9/f32HZGFHPGG/mGCS5G8Hxmii8Gm3hGB3SH2DYAgm7CDLAGrq6ulnSFwa6CCi7Gvz8/DzEGSC4G0vNGBy1G2faGDfCGQK5CGnfGOz64TvDGbjtkez55F7HSD69BSW/HPb98LbrkSizC22/ZVHQGfT87V/XAh28HBy3Gxy2Gzm7DDvCGR/GHrnFuVrVGFLRGPf39zTeJE7JAxy+F3G6cyyzCmDYEjvEGVHRGTS7EjG/Gv39/R29HD28BEvMGEPBBG3gGDLUHRK8CFDbGmneGMbKxh7EHbjDuWPXGGDWGOvr6w25E7fashHGFFbQDSS7GzfTHWbfEsrwsr6+vjW7NDTcHpzoYaa/pjm6PJLWcyTCEEa+JoTOdRrOHND1siC8B1rTF0zZGyrXH6vEqjneIzDgH/v7+6a8p2jYFSi9GtXyx0bkHTjWHV7YFFbRGMDAwM7OzjjCJz/dHG3iGEW5HsvLyyzPHWHYBCLCHSOwBVbTGTHAGkzKIDzVG1bTGFbSGTbCGfL77Si7FtXh1D/PGhe9B0HDFGfgGWziFtfX19Xd1F/UF6rmgrG+sjS5DVzVBCG4D2XbCFDmHQq6DFfVGUa+Pju/FGDXCRfAB6PrZyK7IS++Jiy+KGrhGPDw8GG5ZPv++Wi7aSrZH1vTA1K6VFnSBozNgWfHT7nnoxrKGU7LCRjNGx/OHmnNMuPj4xS9Ch+4BmHDOQ/EEUfaG5PFjijQHi3SHYPRZIzYYjrgHhS6GQ++CWTZGBG6E1/WAjHRHZjjZUHDDkfBCV/VGEbJGVfRA1/EQWfFSGbcGEDiHWfbGFzXGELXG1XQGKnrdmXbGEznHTq8B1bKDjC5NGnbETreHtHzuNX2u17WDEC6HCy9GkfEA6jscCjMHlvXGG7kGSm+G2PbByPGHWjcGMbOxdXyxDzUGyW8HP///yH5BAEAAP8ALAAAAAAYABgAAAj/AP8JHCjwljsO82BxqMODoEOHN8qtA1HNEb4eIFC1gfHQYbs/uj4p8nDFgyJ7Gky5ktFRIA5e717oY+GgJotwW2ih4XatYxoKTcx9sTBBgtEJEyxM++aJwiiHM9KVwaDtwQMEWLM+EAUGA6Ek/Ag+k1fvDgkBaNOmJXGniLhgxAZiylbJErkAePPqBQCgUKRVVgIJ/EVlRwYVAxIrVsyXr5EnNeAIdIZORRUCmDNnbsxXiwpsyAR6C2JgmwEDfCedRs05FR4DnRYJ7FbqgG3OtzmfU2a7FTyBvpjEQLGJs3EAgsahcCIEihyBcyBFuNQv0XG+4Ci1aBEhQg4aAsfYwVGgQNIgdsehnREhIgr5Y70E1kJ0igEDCFjYcN5jDQKEePZlEocmAy3zyj0LLGBCM3zwhUQjgHRgQoIdcKJDAwOFwUoWNiSQwAbM5JIHPWZs4GEC/hgjSygO7TNLCPmkUMCMNM6YwiPSKKHHCQ6dQMQaIQAzxBQ/rLACED50MUwIsbhRQUcNcIELNSUkI8wHH9BBRgmq7OLFky1JcQEpS7wRjQsuiKGOLX6A0kdLBDVQzCGGjDCCGoyAcgScfPb5T0AAOw=="
                                alt="Success:"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <img
                                src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAADoUlEQVR4XrWUX2gcRRzHP7N7t7k0l8Sm0ooFQag0aquoaE1q2xcfGpQUo/UfpFq1IZaUVISCtFAUH3xRKGjR1kqptihKtfokgi+WUopFrVoUCkp8UGtzycVcLrs7Mz83Ow97x23wqR/4HAvH7/udYWZXiQgc3gJKQWFBHyp1+L0CokAR4KlNwI3ALUA7cB74CyuneeNMhcWhAIAI+CR6MDENf/4LvuoG9iIygqEbEVAe+D5oDYpEFbG77wQi+zlwdoIc3A4ODULRhys1+G0KlNoMHMdKD0t7XLCVhikF3oLA5CQgEbCHt84dyC84/ABoCxcugzCOyOsEJZ+OMhjrwgXcjwKF0/Pcrk0MM1WAI7x9/rmcHQzArxWozg8inKKzC/wiGJsFCxkqe8Bf0HNeSRe4nyM/vNJ8BnMhTNZWIhyn1A54cP8wDGwnZWwDubz5DSlfHkt8D8pdMDX1MtvWfM2xn04DICLInruRJ3rfTRQZu09k53ppYbS/yRZ2bXA+dbskOd+muYmuYMeannjrqlBG75XUsX7JZWSdM4/xZGHPJ7M7+yTJEhnu7RMRPADq0eYwNgHGgjakvPooLbxzNrWFFze6udgmGiJjYV4PAq6AWPeJAoxONFAP4e8/YPdG/pcX1kMYuXO0br4YBIRx3JcdstErrRSy1Zu0FKjD03fA0e/I5dk7SdGWRgQPrLkhK/AJTGix2qIULSjykVDTDFiBWBs6FH5WUKISVSO01XiophL/xM8shvrgAubJWxvCBSOgdQwlqTYUyI9LTIjRBhR4roHCR7+QT/MC9GO9iIARQQBTn4NlhYvZe/DM9ffIw8ul9tCq1HDoJsll9DaRHWtFqpMtf9WH0tlUefBaSTJHsmtq4nOUk13Es1hrKGJoYfvNUAthPoJd/TQDJU/S2XYbwTXMYuJPGq6pWfAlyiFlD1Qinx3MpodXw1zMfDVMJTSwbXWW/ulBEKEtURVmwNrXOHq5kn3sHu/CwSm0DBIsB23BU4BALNRDSyPt7e4Dl11TBUxBwV4E1vHhzGxWsLUDB2XgDMJa2lYwNx0RWWFx3Bq6OotgJwH7D9DPx7VLAFnBUBsZ9AAngU0sWwF1D2Y185GlblxZ4Ck6igqWFGBp0b31cAkY4GTowpsKtgQgNBIA48BeoJvOTlLbAlLiGGo1mJoGiIBDwD4+j6oAOQU+CM5meoBHgEHgLuA6HFXge+Ar4H2+MBPk4wquJh5Xmf8AkZZdAsniYaEAAAAASUVORK5CYII="
                                alt="Failed:"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:value-of select="concat(' ',$scenario/@label,' ',@label)"/>
                </h4>
                <xsl:text>
</xsl:text>
                <xsl:if test="not(@result='true')">
                    <xsl:if test="./c:expected">
                        <div>
                            <h5 style="display:inline;">Expected:</h5>
                            <pre class="prettyprint"><xsl:value-of select="./c:expected"/></pre>
                        </div>
                    </xsl:if>
                    <xsl:if test="./c:was">
                        <div>
                            <h5 style="display:inline;">Was:</h5>
                            <pre class="prettyprint"><xsl:value-of select="./c:was"/></pre>
                        </div>
                    </xsl:if>
                </xsl:if>
            </xsl:for-each>
            <hr/>
        </section>
    </xsl:template>

    <xsl:template match="*[namespace-uri()='http://www.w3.org/1999/xhtml']" priority="10">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*">
        <xsl:comment select="concat('Unknown element: ',name())"/>
    </xsl:template>

</xsl:stylesheet>
