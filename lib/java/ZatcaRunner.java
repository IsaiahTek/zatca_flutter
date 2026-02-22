import java.io.*;
import java.util.*;

public class ZatcaRunner {

    public static void main(String[] args) throws Exception {

        BufferedReader reader =
                new BufferedReader(new InputStreamReader(System.in));
        BufferedWriter writer =
                new BufferedWriter(new OutputStreamWriter(System.out));

        String line;

        while ((line = reader.readLine()) != null) {
            try {
                String result = executeCommand(line);
                writer.write(result);
                writer.newLine();
                writer.flush();
            } catch (Exception e) {
                writer.write("{\"exitCode\":-1,\"stdout\":\"\",\"stderr\":\""
                        + escape(e.getMessage()) + "\"}");
                writer.newLine();
                writer.flush();
            }
        }
    }

    private static String executeCommand(String jsonInput) throws Exception {

        String fatooraPath = extractValue(jsonInput, "fatooraPath");
        String workingDirectory = extractValue(jsonInput, "workingDirectory");

        Map<String, String> environment =
                extractEnvironment(jsonInput);

        List<String> args =
                extractArgs(jsonInput);

        return runFatoora(
                fatooraPath,
                args,
                workingDirectory,
                environment
        );
    }

    private static String runFatoora(
            String fatooraPath,
            List<String> args,
            String workingDirectory,
            Map<String, String> env
    ) throws Exception {

        List<String> command = new ArrayList<>();
        command.add(fatooraPath);
        command.addAll(args);

        ProcessBuilder pb = new ProcessBuilder(command);

        if (workingDirectory != null && !workingDirectory.isEmpty()) {
            pb.directory(new File(workingDirectory));
        }

        if (env != null) {
            pb.environment().putAll(env);
        }

        Process process = pb.start();

        BufferedReader stdout =
                new BufferedReader(new InputStreamReader(process.getInputStream()));
        BufferedReader stderr =
                new BufferedReader(new InputStreamReader(process.getErrorStream()));

        StringBuilder out = new StringBuilder();
        StringBuilder err = new StringBuilder();

        String line;

        while ((line = stdout.readLine()) != null) {
            out.append(line).append("\n");
        }

        while ((line = stderr.readLine()) != null) {
            err.append(line).append("\n");
        }

        int exitCode = process.waitFor();

        return "{"
                + "\"exitCode\":" + exitCode + ","
                + "\"stdout\":\"" + escape(out.toString()) + "\","
                + "\"stderr\":\"" + escape(err.toString()) + "\""
                + "}";
    }

    // -------------------------
    // SIMPLE JSON HELPERS
    // -------------------------

    private static String extractValue(String json, String key) {
        String search = "\"" + key + "\":\"";
        int start = json.indexOf(search);
        if (start == -1) return "";
        start += search.length();
        int end = json.indexOf("\"", start);
        return json.substring(start, end);
    }

    private static List<String> extractArgs(String json) {

        List<String> args = new ArrayList<>();

        String search = "\"args\":[";
        int start = json.indexOf(search);
        if (start == -1) return args;

        start += search.length();
        int end = json.indexOf("]", start);

        String argsBlock = json.substring(start, end);

        String[] parts = argsBlock.split(",");

        for (String part : parts) {
            part = part.trim();
            if (part.startsWith("\"") && part.endsWith("\"")) {
                args.add(part.substring(1, part.length() - 1));
            }
        }

        return args;
    }

    private static Map<String, String> extractEnvironment(String json) {

        Map<String, String> map = new HashMap<>();

        String search = "\"environment\":{";
        int start = json.indexOf(search);
        if (start == -1) return map;

        start += search.length();
        int end = json.indexOf("}", start);

        String envBlock = json.substring(start, end);

        String[] entries = envBlock.split(",");

        for (String entry : entries) {
            String[] pair = entry.split(":");
            if (pair.length == 2) {
                String key = pair[0].trim().replace("\"", "");
                String value = pair[1].trim().replace("\"", "");
                map.put(key, value);
            }
        }

        return map;
    }

    private static String escape(String input) {
        if (input == null) return "";
        return input
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "");
    }
}