package correct_script.server.services

import com.google.gson.Gson
import de.kherud.llama.InferenceParameters
import de.kherud.llama.LlamaModel
import de.kherud.llama.ModelParameters
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.io.InputStream
import java.util.concurrent.ArrayBlockingQueue

class LlamaService(
    modelFile: String,
    contextLength: Int,
    private val maxTokensToGen: Int,
    customGrammarFile: String,
    customInitialPromptFile: String,
    numInstances: Int = 2
    ) {
    private val models: MutableList<LlamaModel> = mutableListOf()
    private val availableModels: ArrayBlockingQueue<Int> = ArrayBlockingQueue(numInstances)
    private val grammarString: String
    private val initialPromptString: String
    private val gson = Gson()

    private fun getFromResourceOrCustom(customFile: String, resourceFile: String): String {
        if (customFile.isNotEmpty()) {
            return File(customFile).readText()
        }
        val inputStream: InputStream? = ClassLoader.getSystemResourceAsStream(resourceFile)
        val content = inputStream?.bufferedReader().use { it?.readText() ?: "" }
        return content
    }


    init {
        val modelParams = ModelParameters()
            .setModelFilePath(modelFile)
            .setNCtx(contextLength)
        for (i in 0..<numInstances) {
            models.add(LlamaModel(modelParams))
            availableModels.put(i)
        }
        grammarString = getFromResourceOrCustom(customGrammarFile, "llm_grammar.gbnf")
        initialPromptString = getFromResourceOrCustom(customInitialPromptFile, "initial_prompt.txt")
    }

    suspend fun fixScript(script: String, error: String): String {
        val modelIndex = withContext(Dispatchers.IO) {
            availableModels.take()
        }
        try {
            val model = models[modelIndex]
            val prompt = "$initialPromptString <|user|> {\"script\": \"$script\", \"error\": \"$error\"} <|assistant|>"
            val inferParams = InferenceParameters(prompt).setGrammar(grammarString).setNPredict(maxTokensToGen)
            var jsonString = model.complete(inferParams)
            jsonString = jsonString.replace("<|endoftext|>", "")
            val jsonObject = gson.fromJson(jsonString, Map::class.java)
            return jsonObject["fixedScript"] as? String ?: ""
        } finally {
            withContext(Dispatchers.IO) {
                availableModels.put(modelIndex)
            }
        }
    }
}



