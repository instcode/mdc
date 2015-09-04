import sun.misc.IOUtils;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.ProtocolException;
import java.net.URL;
import java.net.URLEncoder;

public class Main {
    static File workingDir = new File(".");

    public static void main(String[] args) throws IOException {
        //decrypt();
        encrypt();
        //buyOne();
    }

    public static void buyOne() throws IOException {
        //{"code":0,"desc":"","data":{"auth_key":"09e9e1eef1","auth_time":1440042600,"uid":2001874,"game_server":"http://mdc1.menhthientu.com:8002/"}}
        String v = sendRequest("seq=1&uid=2001874&openid=negabox_001597&act=buy_seckilling&auth_key=85e809455e&auth_time=1440042715&mod=activity&args={\"id\":1}&sig=1df9d55f7f&stime=1440040202");
        System.out.println(v);
        //sendRequest("seq=832&uid=2001874&openid=negabox_001597&act=buy_seckilling&auth_key=09e9e1eef1&auth_time=1440042600&mod=activity&args={\"id\":2}&sig=90bdcf907a&stime=1440040203");
        //sendRequest("seq=834&uid=2001874&openid=negabox_001597&act=buy_seckilling&auth_key=09e9e1eef1&auth_time=1440042600&mod=activity&args={\"id\":3}&sig=cdedb30ec9&stime=1440040204");
    }

    private static String sendRequest(String rawData) throws IOException {
        String type = "application/x-www-form-urlencoded";
        String encodedData = rawData;//URLEncoder.encode(rawData);
        URL u = new URL("http://mdc1.menhthientu.com:8002");
        HttpURLConnection conn = (HttpURLConnection) u.openConnection();
        conn.setDoOutput(true);
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", type);
        conn.setRequestProperty("Content-Length", String.valueOf(encodedData.length()));
        OutputStream os = conn.getOutputStream();
        os.write(encodedData.getBytes());
        os.flush();
        return new String(IOUtils.readFully(conn.getInputStream(), -1, false));
    }

    private static void encrypt() throws IOException {
        File panelPath = new File(workingDir, "/scripts/panel");
        File legionPath = new File(workingDir, "/scripts/legion/views");
        File mainscenePath = new File(workingDir, "/scripts/mainscene");
        File dataPath = new File(workingDir, "/scripts/data");
        encrypt(new File(panelPath, "one_ride_panel.lua"));
        encrypt(new File(panelPath, "shop_miaosha_panel.lua"));
        encrypt(new File(legionPath, "legion_kill_role.lua"));
        encrypt(new File(dataPath, "player_core_data.lua"));
        encrypt(new File(mainscenePath, "mainscene_entrance.lua"));
    }

    private static void decrypt() throws IOException {
        //String path = "/external/phone/android/assets/ceremony";
        String path = "/external/phone/com.mtt.nov/files/version/ceremony";

        //String srcpath = "/scripts/";
        String srcpath = "/external/phone/com.mtt.nov/files/version/ceremony";
        recursivelyDecrypt(
                new File(workingDir, path),
                new File(workingDir, srcpath));
    }

    static void encrypt(File file) throws IOException {
        byte[] data = readFile(file, 0);
        byte[] encrypt_data = XXTEA.encrypt(data, "holyshit");

        File outputfile = new File(file.getParent(), file.getName().replace(".lua", ".luac"));
        OutputStream os = new FileOutputStream(outputfile);
        os.write("msanguo".getBytes());
        os.write(encrypt_data);
        os.close();
        System.out.println(XXTEA.decryptToString(encrypt_data, "holyshit"));
    }

    private static void decrypt(File file, File outputDir) throws IOException {
        System.out.println("Processing file: " + file);
        byte[] data = readFile(file, "msanguo".length());
        File outputfile = new File(outputDir, file.getName().replace(".luac", ".lua"));
        OutputStream os = new FileOutputStream(outputfile);
        os.write(XXTEA.decrypt(data, "holyshit"));
        os.close();
        System.out.println("=> output: " + outputfile);
    }

    static void recursivelyDecrypt(File dir, File outputDir) throws IOException {
        for (File file : dir.listFiles()) {
            if (file.isDirectory()) {
                File outputDir1 = new File(outputDir, file.getName());
                outputDir1.mkdirs();
                recursivelyDecrypt(file, outputDir1);
            } else if (file.getName().endsWith(".luac")) {
                decrypt(file, outputDir);
            }
        }
    }

    static byte[] readFile(File file, int skip) throws IOException {
        FileInputStream inputStream = new FileInputStream(file);
        inputStream.skip(skip);
        try {
            return IOUtils.readFully(inputStream, -1, false);
        } finally {
            inputStream.close();
        }
    }
}
