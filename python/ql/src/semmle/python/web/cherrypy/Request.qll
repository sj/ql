import python
import semmle.python.security.TaintTracking
import semmle.python.security.strings.Basic
import semmle.python.web.Http
import semmle.python.web.cherrypy.General

/** The cherrypy.request local-proxy object */
class CherryPyRequest extends TaintKind {
    CherryPyRequest() { this = "cherrypy.request" }

    override TaintKind getTaintOfAttribute(string name) {
        name = "params" and result instanceof ExternalStringDictKind
        or
        name = "cookie" and result instanceof UntrustedCookie
    }

    override TaintKind getTaintOfMethodResult(string name) {
        (
            name = "getHeader" or
            name = "getCookie" or
            name = "getUser" or
            name = "getPassword"
        ) and
        result instanceof ExternalStringKind
    }
}

class CherryPyExposedFunctionParameter extends TaintSource {
    CherryPyExposedFunctionParameter() {
        exists(Parameter p |
            p = any(CherryPyExposedFunction f).getAnArg() and
            not p.isSelf() and
            p.asName().getAFlowNode() = this
        )
    }

    override string toString() { result = "CherryPy handler function parameter" }

    override predicate isSourceOf(TaintKind kind) { kind instanceof ExternalStringKind }
}

class CherryPyRequestSource extends TaintSource {
    CherryPyRequestSource() { this.(ControlFlowNode).pointsTo(Value::named("cherrypy.request")) }

    override predicate isSourceOf(TaintKind kind) { kind instanceof CherryPyRequest }
}
