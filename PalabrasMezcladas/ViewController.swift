//
//  ViewController.swift
//  PalabrasMezcladas
//
//  Created by Pablo Mateo Fernández on 15/01/2017.
//  Copyright © 2017 355 Berry Street S.L. All rights reserved.
//

import UIKit
import GameplayKit


class ViewController: UIViewController {
    
    @IBOutlet weak var pistasLabel: UILabel!
    @IBOutlet weak var respuestasLabel: UILabel!
    @IBOutlet weak var puntuacionLabel: UILabel!
    @IBOutlet weak var respuestaActual: UITextField!
    
    var  silabaBotones = [UIButton]()
    var activadosBotones = [UIButton]()
    var soluciones = [String]()
    
    //Si vamos a usar un propeties observers hay que indicarle que tipo de dato es
    var puntuaciones :Int = 0 {
        didSet {
            puntuacionLabel.text = "Puntuación: \(puntuaciones)"
        }
    }
    var nivel = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Todas las vistas devuelven un array con todos los objetos que tienen dentro 
        for subview in view.subviews where subview.tag == 1001 //recorres el array de subviews pero solo cuyo tag tengan valor 1001 
        {
            let btn = subview as! UIButton
            silabaBotones.append(btn)
            btn.addTarget(self, action: #selector(silabaElegida), for: .touchUpInside)
    
        }
        cargarNivel()
    
    
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func silabaElegida(btn: UIButton){
        respuestaActual.text = respuestaActual.text! + btn.titleLabel!.text!
        activadosBotones.append(btn)
        btn.isHidden = true
    
    }

    func cargarNivel(){
        
        var pistaString = ""
        var solucionString = ""
        var letrasPartes = [String]()
        
        //ACCEDEMOS AL ARCHIVO DEL BUNDLE
        if let nivelPath = Bundle.main.path(forResource: "nivel\(nivel)", ofType: "txt"){ //Accedemos al Bundle de la aplicacion
            
            if let contenidoNivel = try? String(contentsOfFile: nivelPath) //Aquí intentamos coger como un string todo el contenido del path 
            {
                var lineas = contenidoNivel.components(separatedBy: "\n") //Que te meta cada linea en una posicion del array
                lineas = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: lineas) as! [String]//Mezclamos el array
                
                for (index, linea) in lineas.enumerated(){ //Enumerated te devuelve un tupple con posicion y objeto
                    let partes = linea.components(separatedBy: ": ")
                    let respuesta = partes[0]
                    let pista = partes[1]
                    
                    pistaString += "\(index + 1). \(pista)\n"
                    
                    let solucionPalabra = respuesta.replacingOccurrences(of: "|", with: "")
                    
                    solucionString += "\(solucionPalabra.characters.count) letras \n"
                    soluciones.append(solucionPalabra)
                    
                    let trozos = respuesta.components(separatedBy: "|")
                    letrasPartes += trozos
                }
            }
        
        }
        //Configurar botones y labels
        
        pistasLabel.text = pistaString.trimmingCharacters(in: .whitespacesAndNewlines) //Elimina todos los espacios en blanco (tabulaciones, espacios de linea)
        respuestasLabel.text = solucionString.trimmingCharacters(in: .whitespacesAndNewlines)
    
        letrasPartes = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: letrasPartes) as! [String]
        
        if letrasPartes.count == silabaBotones.count{
            for i in 0 ..< letrasPartes.count{
                silabaBotones[i].setTitle(letrasPartes[i], for: .normal)
            }
        }
    }

    @IBAction func enviarSeleccionado(_ sender: AnyObject) {
        
        if let solucionPosicion = soluciones.index(of: respuestaActual.text!) //Busca por un array el item que le mandamos
        {
            activadosBotones.removeAll()
            
            var separarPistas = respuestasLabel.text!.components(separatedBy: "\n")
            separarPistas[solucionPosicion] = respuestaActual.text!
            respuestasLabel.text = separarPistas.joined(separator: "\n")
            
            respuestaActual.text = ""
            puntuaciones += 1
            
            if puntuaciones % 7 == 0{
                let ac = UIAlertController(title: "Genial!", message: "Has superado el nivel", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: subirNivel))
                present(ac, animated: true)
            
            }
            
        }
        
    }
    
    func subirNivel(action: UIAlertAction){
    
        nivel += 1
        soluciones.removeAll(keepingCapacity: true)
        
        cargarNivel()
        
    
    }
    @IBAction func borrarSeleccionado(_ sender: AnyObject) {
        
        respuestaActual.text = ""
        
        for btn in activadosBotones{
            btn.isHidden = false
            
        }
        activadosBotones.removeAll()
    }
}

