import javax.swing.*;
import java.awt.*;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;

public class MenuApp {
    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            JFrame frame = new JFrame("SHA3-512 Base64 Generator");
            frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
            frame.setSize(700, 350);
            frame.setLocationRelativeTo(null);

            // --- MENU BAR SECTION ---
            JMenuBar menuBar = new JMenuBar();
            String[] menuNames = {"File", "Edit", "View", "Insert", "Tools", "Help"};
            for (String name : menuNames) {
                JMenu menu = new JMenu(name);
                JMenuItem exitItem = new JMenuItem("Exit");
                exitItem.addActionListener(e -> System.exit(0));
                menu.add(exitItem);
                menuBar.add(menu);
            }
            frame.setJMenuBar(menuBar);

            // --- GUI LAYOUT SECTION ---
            JPanel panel = new JPanel();
            panel.setLayout(new GridLayout(5, 1, 10, 10)); // Added a row for clarity
            panel.setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));

            JTextField inputField = new JTextField();
            JButton calcButton = new JButton("Calculate SHA3-512 (Base64)");
            JTextField outputField = new JTextField();
            outputField.setEditable(false); 

            panel.add(new JLabel("Enter Text:"));
            panel.add(inputField);
            panel.add(calcButton);
            panel.add(new JLabel("Base64 Result:"));
            panel.add(outputField);

            // --- LOGIC SECTION ---
            calcButton.addActionListener(e -> {
                String input = inputField.getText();
                if (!input.isEmpty()) {
                    String hash = calculateSHA3Base64(input);
                    outputField.setText(hash);
                }
            });

            frame.add(panel);
            frame.setVisible(true);
        });
    }

    private static String calculateSHA3Base64(String input) {
        try {
            MessageDigest crypt = MessageDigest.getInstance("SHA3-512");
            byte[] hashBytes = crypt.digest(input.getBytes());
            
            // Encode the resulting bytes to Base64 string
            return Base64.getEncoder().encodeToString(hashBytes);
            
        } catch (NoSuchAlgorithmException e) {
            return "Error: SHA3-512 algorithm not found.";
        }
    }
}