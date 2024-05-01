package correct_script.server.plugins

import correct_script.server.services.LlamaService
import com.google.gson.Gson
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.serialization.gson.*
import io.ktor.server.plugins.contentnegotiation.*
import kotlinx.coroutines.ExecutorCoroutineDispatcher
import kotlinx.coroutines.asCoroutineDispatcher
import kotlinx.coroutines.withContext
import java.util.concurrent.Executors

data class FixScriptRequest(val script: String, val error: String)
data class FixScriptResponse(val fixedScript: String)



fun Application.configureRouting(llamaService: LlamaService, llamaModelDispatcher: ExecutorCoroutineDispatcher) {
    install(ContentNegotiation) {
        gson()
    }

    routing {
        post("/fix-script") {
            val request = call.receive<FixScriptRequest>()
            val (fixedScriptString, fromModel) = withContext(llamaModelDispatcher) {
                llamaService.fixScript(request.script, request.error)
            }
            val response = FixScriptResponse(fixedScriptString)
            call.application.environment.log.info("Received a fixed script $response from model number $fromModel on response $response")
            call.respond(HttpStatusCode.OK, response)
        }
    }
}