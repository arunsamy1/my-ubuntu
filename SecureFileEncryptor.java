import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import javax.swing.*;
import java.awt.*;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.security.SecureRandom;
import java.util.Arrays;

public class SecureFileEncryptor extends JFrame {

    private JTextField pathDisplay;
    private JTextField keyField; // New field for the encryption key
    private File selectedFile;
    private final String ALGORITHM = "AES/CBC/PKCS5Padding";

    public SecureFileEncryptor() {
        setTitle("AES File Encryptor");
        setSize(550, 280);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);
        setLayout(new BorderLayout(10, 10));

        // 1. Menu Bar
        JMenuBar menuBar = new JMenuBar();
        JMenu fileMenu = new JMenu("File");
        JMenuItem openItem = new JMenuItem("Open File...");
        JMenuItem exitItem = new JMenuItem("Exit");

        openItem.addActionListener(e -> selectFile());
        exitItem.addActionListener(e -> System.exit(0));

        fileMenu.add(openItem);
        fileMenu.addSeparator();
        fileMenu.add(exitItem);
        menuBar.add(fileMenu);
        setJMenuBar(menuBar);

        // 2. UI Components
        JPanel mainPanel = new JPanel(new GridLayout(5, 1, 5, 5));
        mainPanel.setBorder(BorderFactory.createEmptyBorder(15, 20, 15, 20));

        mainPanel.add(new JLabel("Selected File Path:"));
        pathDisplay = new JTextField("No file selected...");
        pathDisplay.setEditable(false);
        mainPanel.add(pathDisplay);

        mainPanel.add(new JLabel("Encryption Key (16 chars recommended):"));
        keyField = new JTextField("mySecretKey12345"); // Default key
        mainPanel.add(keyField);

        JButton encryptButton = new JButton("Encrypt and Save");
        encryptButton.setFont(new Font("SansSerif", Font.BOLD, 12));
        encryptButton.addActionListener(e -> {
            if (selectedFile != null) {
                encryptFile(selectedFile);
            } else {
                JOptionPane.showMessageDialog(this, "Please select a file first via File > Open.");
            }
        });

        add(mainPanel, BorderLayout.CENTER);
        add(encryptButton, BorderLayout.SOUTH);
    }

    private void selectFile() {
        JFileChooser fileChooser = new JFileChooser();
        int result = fileChooser.showOpenDialog(this);
        if (result == JFileChooser.APPROVE_OPTION) {
            selectedFile = fileChooser.getSelectedFile();
            pathDisplay.setText(selectedFile.getAbsolutePath());
        }
    }

    private void encryptFile(File inputFile) {
        String userKey = keyField.getText();
        if (userKey.isEmpty()) {
            JOptionPane.showMessageDialog(this, "Key cannot be empty!");
            return;
        }

        try {
            // Normalize key to 16 bytes (128-bit)
            byte[] keyBytes = new byte[16];
            byte[] originalKeyBytes = userKey.getBytes("UTF-8");
            System.arraycopy(originalKeyBytes, 0, keyBytes, 0, Math.min(originalKeyBytes.length, 16));
            
            SecretKeySpec keySpec = new SecretKeySpec(keyBytes, "AES");

            // Setup IV
            byte[] iv = new byte[16];
            new SecureRandom().nextBytes(iv);
            IvParameterSpec ivSpec = new IvParameterSpec(iv);

            Cipher cipher = Cipher.getInstance(ALGORITHM);
            cipher.init(Cipher.ENCRYPT_MODE, keySpec, ivSpec);

            // Filename logic: document.txt -> document_enc.txt
            String inputName = inputFile.getName();
            String outputName;
            int dotIndex = inputName.lastIndexOf('.');
            if (dotIndex > 0) {
                outputName = inputName.substring(0, dotIndex) + "_enc" + inputName.substring(dotIndex);
            } else {
                outputName = inputName + "_enc";
            }

            File outputFile = new File(inputFile.getParent(), outputName);

            try (FileInputStream fis = new FileInputStream(inputFile);
                 FileOutputStream fos = new FileOutputStream(outputFile)) {
                
                fos.write(iv); // Prepend IV for decryption

                byte[] buffer = new byte[4096];
                int bytesRead;
                while ((bytesRead = fis.read(buffer)) != -1) {
                    byte[] output = cipher.update(buffer, 0, bytesRead);
                    if (output != null) fos.write(output);
                }
                byte[] finalBytes = cipher.doFinal();
                if (finalBytes != null) fos.write(finalBytes);
            }

            JOptionPane.showMessageDialog(this, "Encrypted successfully!\nSaved as: " + outputName);

        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this, "Error: " + ex.getMessage(), "Encryption Error", JOptionPane.ERROR_MESSAGE);
        }
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> new SecureFileEncryptor().setVisible(true));
    }
}