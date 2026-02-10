import javax.swing.*;
import java.awt.*;
import java.security.SecureRandom;

public class PasswordGeneratorGUI extends JFrame {

    private JSlider lengthSlider;
    private JCheckBox upperCheck, lowerCheck, numberCheck;
    private JTextField passwordOutput;
    private final SecureRandom random = new SecureRandom();

    public PasswordGeneratorGUI() {
        // Window Configuration
        setTitle("Secure Password Generator");
        setSize(400, 350);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);
        setLayout(new BorderLayout(10, 10));

        // 1. Menu Bar
        JMenuBar menuBar = new JMenuBar();
        JMenu fileMenu = new JMenu("File");
        JMenuItem exitItem = new JMenuItem("Exit");
        exitItem.addActionListener(e -> System.exit(0));
        fileMenu.add(exitItem);
        menuBar.add(fileMenu);
        setJMenuBar(menuBar);

        // 2. Control Panel (Checkboxes and Slider)
        JPanel controlPanel = new JPanel();
        controlPanel.setLayout(new BoxLayout(controlPanel, BoxLayout.Y_AXIS));
        controlPanel.setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));

        JLabel sliderLabel = new JLabel("Password Length: 12");
        lengthSlider = new JSlider(4, 20, 12);
        lengthSlider.setMajorTickSpacing(4);
        lengthSlider.setMinorTickSpacing(1);
        lengthSlider.setPaintTicks(true);
        lengthSlider.setPaintLabels(true);
        lengthSlider.addChangeListener(e -> sliderLabel.setText("Password Length: " + lengthSlider.getValue()));

        upperCheck = new JCheckBox("Include Uppercase (A-Z)", true);
        lowerCheck = new JCheckBox("Include Lowercase (a-z)", true);
        numberCheck = new JCheckBox("Include Numbers (0-9)", true);

        controlPanel.add(sliderLabel);
        controlPanel.add(lengthSlider);
        controlPanel.add(Box.createVerticalStrut(10));
        controlPanel.add(upperCheck);
        controlPanel.add(lowerCheck);
        controlPanel.add(numberCheck);

        // 3. Output Panel
        JPanel outputPanel = new JPanel(new BorderLayout(5, 5));
        outputPanel.setBorder(BorderFactory.createEmptyBorder(0, 20, 20, 20));
        
        passwordOutput = new JTextField();
        passwordOutput.setEditable(false);
        passwordOutput.setFont(new Font("Monospaced", Font.BOLD, 16));
        passwordOutput.setHorizontalAlignment(JTextField.CENTER);

        JButton generateBtn = new JButton("Generate Password");
        generateBtn.addActionListener(e -> generatePassword());

        outputPanel.add(generateBtn, BorderLayout.NORTH);
        outputPanel.add(passwordOutput, BorderLayout.CENTER);

        add(controlPanel, BorderLayout.CENTER);
        add(outputPanel, BorderLayout.SOUTH);
    }

    private void generatePassword() {
        String upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        String lower = "abcdefghijklmnopqrstuvwxyz";
        String numbers = "0123456789";
        
        StringBuilder characterPool = new StringBuilder();
        if (upperCheck.isSelected()) characterPool.append(upper);
        if (lowerCheck.isSelected()) characterPool.append(lower);
        if (numberCheck.isSelected()) characterPool.append(numbers);

        if (characterPool.length() == 0) {
            JOptionPane.showMessageDialog(this, "Please select at least one character set.");
            return;
        }

        int length = lengthSlider.getValue();
        StringBuilder password = new StringBuilder();
        for (int i = 0; i < length; i++) {
            int index = random.nextInt(characterPool.length());
            password.append(characterPool.charAt(index));
        }

        passwordOutput.setText(password.toString());
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> new PasswordGeneratorGUI().setVisible(true));
    }
}