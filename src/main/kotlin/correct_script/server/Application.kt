package correct_script.server

import correct_script.server.plugins.*
import correct_script.server.plugins.configureRouting
import correct_script.server.plugins.configureSecurity
import correct_script.server.services.LlamaService
import io.ktor.server.application.*
import kotlinx.coroutines.asCoroutineDispatcher
import java.util.concurrent.Executors
import kotlin.math.min

fun main(args: Array<String>) {
    io.ktor.server.netty.EngineMain.main(args)
}

fun Application.module() {
    val numLlmInstances: Int = environment.config.property("llama_cpp.num_llm_instances").getString().toInt()
    val numThreads = min(numLlmInstances, Runtime.getRuntime().availableProcessors())
    val llamaModelDispatcher = Executors.newFixedThreadPool(numThreads).asCoroutineDispatcher()

    val modelFile = environment.config.property("llama_cpp.model_file").getString()

    if (!modelFile.endsWith(".gguf")) {
        throw IllegalArgumentException("model_file in .gguf format required")
    }

    val llamaService = LlamaService(
        modelFile=environment.config.property("llama_cpp.model_file").getString(),
        contextLength=environment.config.property("llama_cpp.context_length").getString().toInt(),
        maxTokensToGen=environment.config.property("llama_cpp.max_tokens_to_gen").getString().toInt(),
        customInitialPromptFile=environment.config.property("llama_cpp.custom_initial_prompt_file").getString(),
        numInstances = numLlmInstances
        )

    configureRouting(llamaService, llamaModelDispatcher)
}
