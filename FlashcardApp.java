import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.KeyEvent;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class FlashcardApp extends JFrame {
    private JTextArea questionArea;
    private JButton nextButton, prevButton;
    private List<String> questions;
    private int currentIndex = 0;

    public FlashcardApp() {
        questions = new ArrayList<>();
        
        setTitle("Java Flashcards");
        setSize(500, 350);
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setLayout(new BorderLayout());

        questionArea = new JTextArea("1. Open a file\n2. Use N/P or Arrow Keys to navigate");
        questionArea.setEditable(false);
        questionArea.setLineWrap(true);
        questionArea.setWrapStyleWord(true);
        questionArea.setFont(new Font("Arial", Font.PLAIN, 18));
        questionArea.setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));

        prevButton = new JButton("Previous (P)");
        nextButton = new JButton("Next (N)");
        prevButton.setEnabled(false);
        nextButton.setEnabled(false);

        prevButton.addActionListener(e -> showPreviousQuestion());
        nextButton.addActionListener(e -> showNextQuestion());

        // Setup Key Bindings
        setupKeyBindings();

        JButton loadButton = new JButton("Open File");
        loadButton.addActionListener(e -> loadFile());

        JPanel buttonPanel = new JPanel();
        buttonPanel.add(loadButton);
        buttonPanel.add(prevButton);
        buttonPanel.add(nextButton);

        add(new JScrollPane(questionArea), BorderLayout.CENTER);
        add(buttonPanel, BorderLayout.SOUTH);
        
        setLocationRelativeTo(null);
    }

    private void setupKeyBindings() {
        InputMap im = getRootPane().getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW);
        ActionMap am = getRootPane().getActionMap();

        // Next Actions (N or Right Arrow)
        im.put(KeyStroke.getKeyStroke(KeyEvent.VK_N, 0), "next");
        im.put(KeyStroke.getKeyStroke(KeyEvent.VK_RIGHT, 0), "next");
        am.put("next", new AbstractAction() {
            public void actionPerformed(ActionEvent e) { if(nextButton.isEnabled()) showNextQuestion(); }
        });

        // Previous Actions (P or Left Arrow)
        im.put(KeyStroke.getKeyStroke(KeyEvent.VK_P, 0), "prev");
        im.put(KeyStroke.getKeyStroke(KeyEvent.VK_LEFT, 0), "prev");
        am.put("prev", new AbstractAction() {
            public void actionPerformed(ActionEvent e) { if(prevButton.isEnabled()) showPreviousQuestion(); }
        });
    }

    private void loadFile() {
        JFileChooser fileChooser = new JFileChooser();
        if (fileChooser.showOpenDialog(this) == JFileChooser.APPROVE_OPTION) {
            questions.clear();
            try (BufferedReader reader = new BufferedReader(new FileReader(fileChooser.getSelectedFile()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    if (!line.trim().isEmpty()) questions.add(line);
                }
                if (!questions.isEmpty()) {
                    currentIndex = 0;
                    displayQuestion();
                    nextButton.setEnabled(true);
                    prevButton.setEnabled(true);
                }
            } catch (IOException ex) {
                JOptionPane.showMessageDialog(this, "Error reading file");
            }
        }
    }

    private void displayQuestion() {
        questionArea.setText(questions.get(currentIndex));
    }

    private void showNextQuestion() {
        currentIndex = (currentIndex + 1) % questions.size();
        displayQuestion();
    }

    private void showPreviousQuestion() {
        currentIndex = (currentIndex - 1 + questions.size()) % questions.size();
        displayQuestion();
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> new FlashcardApp().setVisible(true));
    }
}