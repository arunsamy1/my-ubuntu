import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;

public class HashGeneratorGUI extends JFrame {

    private JTextField inputField;
    private JTextArea resultArea;

    public HashGeneratorGUI() {
        // 1. Setup Window Frame
        setTitle("SHA3-512 Hash Generator");
        setSize(500, 300);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);
        setLayout(new BorderLayout(10, 10));

        // 2. Create Menu Bar
        JMenuBar menuBar = new JMenuBar();
        JMenu fileMenu = new JMenu("File");
        JMenuItem exitItem = new JMenuItem("Exit");
        
        exitItem.addActionListener(e -> System.exit(0));
        fileMenu.add(exitItem);
        menuBar.add(fileMenu);
        setJMenuBar(menuBar);

        // 3. Setup Components
        inputField = new JTextField();
        JButton hashButton = new JButton("Generate SHA3-512 (Base64)");
        resultArea = new JTextArea(3, 20);
        resultArea.setLineWrap(true);
        resultArea.setWrapStyleWord(true);
        resultArea.setEditable(false);

        // 4. Layout Panels
        JPanel topPanel = new JPanel(new GridLayout(2, 1, 5, 5));
        topPanel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));
        topPanel.add(new JLabel("Enter text below:"));
        topPanel.add(inputField);

        JPanel centerPanel = new JPanel(new BorderLayout());
        centerPanel.setBorder(BorderFactory.createEmptyBorder(0, 10, 10, 10));
        centerPanel.add(hashButton, BorderLayout.NORTH);
        centerPanel.add(new JScrollPane(resultArea), BorderLayout.CENTER);

        add(topPanel, BorderLayout.NORTH);
        add(centerPanel, BorderLayout.CENTER);

        // 5. Button Logic
        hashButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                generateHash();
            }
        });
    }

    private void generateHash() {
        String input = inputField.getText();
        if (input.isEmpty()) {
            JOptionPane.showMessageDialog(this, "Please enter some text.");
            return;
        }

        try {
            // SHA3-512 instance
            MessageDigest digest = MessageDigest.getInstance("SHA3-512");
            byte[] hashBytes = digest.digest(input.getBytes());
            
            // Encode to Base64
            String base64Hash = Base64.getEncoder().encodeToString(hashBytes);
            resultArea.setText(base64Hash);
            
        } catch (NoSuchAlgorithmException ex) {
            JOptionPane.showMessageDialog(this, "Error: SHA3-512 algorithm not found.");
        }
    }

    public static void main(String[] args) {
        // Ensure UI is created on the Event Dispatch Thread
        SwingUtilities.invokeLater(() -> {
            new HashGeneratorGUI().setVisible(true);
        });
    }
}