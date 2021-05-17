package dev.pedroz.meta

import com.github.javiersantos.piracychecker.BuildConfig
import com.github.javiersantos.piracychecker.PiracyChecker
import dev.jahir.blueprint.ui.activities.BottomNavigationBlueprintActivity

class MainActivity : BottomNavigationBlueprintActivity() {

    override val billingEnabled = true

    override fun amazonInstallsEnabled(): Boolean = false
    override fun checkLPF(): Boolean = true
    override fun checkStores(): Boolean = true
    override val isDebug: Boolean = BuildConfig.DEBUG

    override fun getLicKey(): String = "MIIBIjANBgkqhkiGgKglYGYGihLuihUuhhuBlouBkuiu"

    override fun getLicenseChecker(): PiracyChecker? {
        destroyChecker()
        return null
    }

    override fun defaultTheme(): Int = R.style.MyApp_Default
    override fun amoledTheme(): Int = R.style.MyApp_Default_Amoled
}