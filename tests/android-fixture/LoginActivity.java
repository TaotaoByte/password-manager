package dev.localvault.fixture;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.InputType;
import android.view.View;
import android.view.autofill.AutofillManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

/** Test only. No network permission, storage or credential logging. */
public class LoginActivity extends Activity {
    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        LinearLayout content = new LinearLayout(this);
        content.setOrientation(LinearLayout.VERTICAL);
        content.setPadding(48, 160, 48, 48);
        TextView title = new TextView(this);
        title.setText("LocalVault 自动填充验收（仅虚构账号）");
        content.addView(title);
        Button open = new Button(this);
        open.setText("打开互通测试库");
        content.addView(open);
        open.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View view) {
                startActivity(new Intent(Intent.ACTION_VIEW)
                    .setDataAndType(Uri.parse("content://dev.localvault.fixture.vault/test.kdbx"), "application/octet-stream")
                    .setPackage("dev.localvault.keepassdx.libre")
                    .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION));
            }
        });
        EditText user = new EditText(this);
        user.setId(101);
        user.setHint("Username");
        user.setAutofillHints(View.AUTOFILL_HINT_USERNAME);
        user.setInputType(InputType.TYPE_CLASS_TEXT);
        content.addView(user);
        EditText password = new EditText(this);
        password.setId(102);
        password.setHint("Password");
        password.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
        password.setAutofillHints(View.AUTOFILL_HINT_PASSWORD);
        content.addView(password);
        Button commit = new Button(this);
        commit.setText("模拟登录并请求保存");
        content.addView(commit);
        TextView status = new TextView(this);
        status.setImportantForAutofill(View.IMPORTANT_FOR_AUTOFILL_NO);
        content.addView(status);
        commit.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View view) {
                getSystemService(AutofillManager.class).commit();
                status.setText("已提交表单；未发送、保存或记录密码。");
            }
        });
        setContentView(content);
    }
}
